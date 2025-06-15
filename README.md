# iOS Keyboard extension POC

A **SwiftUI** keyboard embeded in UIKit extension (_no choice extensions are UIKIT based_).

Magic done thanks to [SVGKit]](github.com/SVGKit/SVGKit) 🪄

Preview

| Keyboard                          | input                           |
| --------------------------------- | ------------------------------- |
| ![Keyboard preview](/preview.png) | ![input preview](/preview2.png) |

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
