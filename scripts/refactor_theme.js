const fs = require('fs');
const path = require('path');

const mappings = {
  'AppTheme.bgColor': 'Theme.of(context).scaffoldBackgroundColor',
  'AppTheme.textColor': 'Theme.of(context).colorScheme.onSurface',
  'AppTheme.mapBg': 'Theme.of(context).colorScheme.surface',
  'AppTheme.mapStroke': 'Theme.of(context).colorScheme.outline',
  'AppTheme.countryFill': 'Theme.of(context).colorScheme.surfaceContainer',
  'AppTheme.countryHover': 'Theme.of(context).colorScheme.surfaceContainerHigh',
  'AppTheme.panelBg': 'Theme.of(context).cardColor',
  'AppTheme.ink1': 'Theme.of(context).colorScheme.surfaceTint',
};

function processDirectory(directory) {
  const files = fs.readdirSync(directory);
  
  for (const file of files) {
    const fullPath = path.join(directory, file);
    const stat = fs.statSync(fullPath);
    
    if (stat.isDirectory()) {
      processDirectory(fullPath);
    } else if (fullPath.endsWith('.dart') && !fullPath.includes('app_theme.dart') && !fullPath.includes('main.dart')) {
      let content = fs.readFileSync(fullPath, 'utf8');
      let changed = false;
      
      for (const [key, value] of Object.entries(mappings)) {
        if (content.includes(key)) {
          // If we replace a constant with Theme.of(context), we must ensure it's not preceded by 'const '
          // because Theme.of(context) is not constant.
          // This regex looks for 'const ' optionally followed by some space and then a widget that contains the key.
          // It's safer to just replace the key, then run flutter analyze and manually fix the const issues,
          // OR remove const from the immediate parent.
          // A simple approach: just replace 'const TextStyle(' with 'TextStyle(', 'const BorderSide(' with 'BorderSide(', etc.
          // if they contain AppTheme variables.
          
          content = content.split(key).join(value);
          changed = true;
        }
      }
      
      if (changed) {
        // Broadly strip const from common widgets if they use Theme.of(context)
        content = content.replace(/const\s+TextStyle\([^)]*Theme\.of\(context\)[^)]*\)/g, match => match.replace('const ', ''));
        content = content.replace(/const\s+BorderSide\([^)]*Theme\.of\(context\)[^)]*\)/g, match => match.replace('const ', ''));
        content = content.replace(/const\s+BoxDecoration\([^)]*Theme\.of\(context\)[^)]*\)/g, match => match.replace('const ', ''));
        
        fs.writeFileSync(fullPath, content, 'utf8');
        console.log(`Updated ${fullPath}`);
      }
    }
  }
}

processDirectory(path.join(__dirname, '../lib'));
