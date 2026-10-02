---
name: ui-preferences
description: "Always load when building, changing, prototyping, or reviewing the app's UI: components, styles, layout, copy, or motion."
---

# UI preferences

The developer's taste for the app's interface. The [theme contract](../../../docs/agents/contracts/theme.md) holds the binding tokens and layout rules; these preferences guide every choice the contract leaves open.

Make the change that was asked for; don't redesign around it. Raise a broader design issue as a suggestion instead of acting on it.

- Structure first. This stage is about placement, grouping, order, alignment, and spacing. Motion, type variety, color, light mode, personalization, and theming are later layers; don't build tokens or settings for them ahead of time.
- Dark mode.
- Simplicity, not minimalism: cut what doesn't earn its place, but keep the context that makes the main task obvious.
- True black (#000) background.
- White primary text. Essentially black and white, with a few deliberate exceptions.
- Favor information density.
- Avoid decorative card and pill chrome.
- Avoid unnecessary light-gray subtitle lines above sections.
- Almost no copy. Show labels and values only; no explanatory sentences, helper text, or instructions. When something needs words to be understood, fix the control or layout instead.
- Avoid em dashes.
- Almost no animation. State changes render instantly: no transitions, keyframes, animated blur, or other motion effects unless the developer asks for a specific one, and existing ones are removal candidates.
- One interface font, one size, one weight. The authored-type surfaces in the theme contract are the exception.
- Pay attention to performance details such as dropped frames, misleading loading states, and stale UI.
