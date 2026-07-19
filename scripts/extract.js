const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');

const htmlPath = '/Users/richard/Downloads/atlas-carnet-de-voyage.html';
const htmlContent = fs.readFileSync(htmlPath, 'utf8');

const $ = cheerio.load(htmlContent);

// 1. Extract COUNTRIES
const countriesMatch = htmlContent.match(/const COUNTRIES = (\{[\s\S]*?\});/);
let countriesStr = countriesMatch ? countriesMatch[1] : '{}';

// 2. Extract CITIES
const citiesMatch = htmlContent.match(/const CITIES = (\{[\s\S]*?\});/);
let citiesStr = citiesMatch ? citiesMatch[1] : '{}';

// 3. Extract Continent labels
const continentsMatch = htmlContent.match(/const CONTINENT_LABELS = (\{[\s\S]*?\});/);
let continentsStr = continentsMatch ? continentsMatch[1] : '{}';

// Format for Dart
const countriesData = eval('(' + countriesStr + ')');
const citiesData = eval('(' + citiesStr + ')');
const continentsData = continentsMatch ? eval('(' + continentsStr + ')') : {"af":"Afrique","an":"Antarctique","as":"Asie","eu":"Europe","na":"Amérique du Nord","oc":"Océanie","sa":"Amérique du Sud"};


let countriesDart = `// Generated file
class CountryData {
  final String name;
  final String continent;
  const CountryData({required this.name, required this.continent});
}

const Map<String, CountryData> countriesData = {
`;
for (const [code, data] of Object.entries(countriesData)) {
  countriesDart += `  '${code}': CountryData(name: "${data.name.replace(/"/g, '\\"')}", continent: "${data.continent}"),\n`;
}
countriesDart += `};\n`;
fs.writeFileSync(path.join(__dirname, '../lib/data/countries.dart'), countriesDart);


let citiesDart = `// Generated file
class CityData {
  final String name;
  final double x;
  final double y;
  const CityData({required this.name, required this.x, required this.y});
}

const Map<String, List<CityData>> citiesData = {
`;
for (const [code, cities] of Object.entries(citiesData)) {
  citiesDart += `  '${code}': [\n`;
  for (const city of cities) {
    citiesDart += `    CityData(name: "${city.n.replace(/"/g, '\\"')}", x: ${city.x}, y: ${city.y}),\n`;
  }
  citiesDart += `  ],\n`;
}
citiesDart += `};\n`;
fs.writeFileSync(path.join(__dirname, '../lib/data/cities.dart'), citiesDart);


let continentsDart = `// Generated file
const Map<String, String> continentLabels = {
`;
for (const [code, label] of Object.entries(continentsData)) {
  continentsDart += `  '${code}': "${label.replace(/"/g, '\\"')}",\n`;
}
continentsDart += `};\n`;
fs.writeFileSync(path.join(__dirname, '../lib/data/continent_labels.dart'), continentsDart);


// 4. SVG Paths extraction
const svg = $('svg#worldmap');
let pathsDart = `// Generated file
class MapPath {
  final String id;
  final String? className;
  final String d;
  const MapPath({required this.id, this.className, required this.d});
}

class MapGroup {
  final String id;
  final List<MapPath> paths;
  const MapGroup({required this.id, required this.paths});
}

const List<MapGroup> worldMapData = [
`;

// In the HTML, countries are either direct \`<path id="...">\` or \`<g id="...">\` with multiple \`<path>\` children.
// The script will collect all countries into \`MapGroup\`s for consistency.

$('#mapGroup').children().each((_, el) => {
  const $el = $(el);
  const tagName = el.tagName.toLowerCase();
  
  if (tagName === 'path') {
    const id = $el.attr('id');
    const className = $el.attr('class');
    const d = $el.attr('d');
    if (id && id !== 'bg-ocean') {
      pathsDart += `  MapGroup(id: '${id}', paths: [MapPath(id: '${id}', className: ${className ? "'" + className + "'" : 'null'}, d: '${d}')]),\n`;
    }
  } else if (tagName === 'g') {
    const id = $el.attr('id');
    if (id && id !== 'zoomGroup') { // Make sure it's a country group
      pathsDart += `  MapGroup(id: '${id}', paths: [\n`;
      $el.children('path').each((_, pathEl) => {
        const $path = $(pathEl);
        const pid = $path.attr('id');
        const pclass = $path.attr('class');
        const pd = $path.attr('d');
        pathsDart += `    MapPath(id: '${pid || ''}', className: ${pclass ? "'" + pclass + "'" : 'null'}, d: '${pd}'),\n`;
      });
      pathsDart += `  ]),\n`;
    }
  }
});

pathsDart += `];\n`;
fs.writeFileSync(path.join(__dirname, '../lib/data/world_map_paths.dart'), pathsDart);

console.log("Extraction complete.");
