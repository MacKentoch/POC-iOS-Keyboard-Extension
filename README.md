# iOS Keyboard extension  POC

A SwiftUI keyboard embeded in UIKit extension (no choice extension are UIKIT).

> Easily maintainable by just editing a JSON file `KeyboardLayout.json` supporting JSON SVG as Button image.

Example
```JSON
{
    "rows": [
        {
            "keys": [
                { "type": { "svgImage": "MONKEY_EYE" }, "action": { "insert": "🙈" } },
                { "type": { "character": "O" }, "action": { "insert": "b" } },
                { "type": { "systemImage": "return" }, "action": { "insert": "\n" }, "width": 80 }
                
            ]
        },
```

