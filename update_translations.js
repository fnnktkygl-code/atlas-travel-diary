const fs = require('fs');
let c = fs.readFileSync('lib/l10n/translations.dart', 'utf8');
let parts = c.split("'remove_country': 'Supprimer ce pays',");
if (parts.length === 4) {
    c = parts[0] + "'remove_country': 'Supprimer ce pays'," + 
        parts[1] + "'remove_country': 'Remove country'," + 
        parts[2] + "'remove_country': 'Eliminar país'," + parts[3];
    fs.writeFileSync('lib/l10n/translations.dart', c);
}
