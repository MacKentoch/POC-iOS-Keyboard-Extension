# iOS Keyboard extension  POC

A SwiftUI keyboard embeded in UIKit extension (no choice extension are UIKIT).

> Easily maintainable by just editing a JSON file `KeyboardLayout.json` supporting JSON SVG as Button image.

Example
```JSON
{
    "rows": [
        {
            "keys": [
                { "type": { "svgImage": "MONKEY_EYE" }, "action": { "insert": "🙈" }, "width": 45 },
                { "type": { "character": "O" }, "action": { "insert": "b" } },
                { "type": { "systemImage": "return" }, "action": { "insert": "\n" }, "width": 80 }
                
            ]
        },
```

### NOTE: svg should be sized to 128x128
 
```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128">
    <!-- ... ... -->
</svg>
```
