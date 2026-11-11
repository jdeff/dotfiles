// A tab strip for a layout `stack`: one tab per child, the active one raised.
// Used as the stack's header: { "content": { "mod": "sidebar-tabs", "props": {
//   "stack": "<stack id>", "tabs": [{ "id": "<child id>", "label": "…" }] } } }
//
// A tab that's not showing gets a dot when something there needs you:
//   agents  — an agent is blocked (asking), from the app's own agents()
//   muster  — the muster mod's shared "muster.health" ({ exited, busy })

import { View, div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { agents, layout, props, run, shared, theme } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// What a hidden tab should flag, as a theme color name, or null.
function attention(id) {
  if (id === "agents") return agents().some((a) => a.status === "blocked") ? "blocked" : null;
  if (id === "muster") {
    const h = shared("muster.health");
    return h?.exited ? "blocked" : h?.busy ? "working" : null;
  }
  return null;
}

export default class SidebarTabs extends View {
  render() {
    const t = theme();
    const { stack, tabs = [] } = props() ?? {};
    const active = find(layout(), stack)?.active ?? tabs[0]?.id;
    return h_flex().size_full().px(10).gap(2).items_end().bg(t.chrome).border_t(1).border_color(t.border)
      .children(tabs.map((tab) => {
        const on = tab.id === active;
        const flag = on ? null : attention(tab.id);
        return h_flex().id(`st-${tab.id}`).h(26).px(9).gap(6).items_center().rounded_t(7)
          .text_size(12).font_medium()
          .text_color(on ? t.foreground : t.dim)
          .when(on, (el) => el.bg(t.raised))
          .cursor_pointer().hover((s) => s.text_color(t.foreground))
          .on_click(() => run("layout.select", { stack, child: tab.id }))
          .child(tab.label)
          .when(Boolean(flag), (el) => el.child(div().size(6).rounded(3).bg(t[flag])));
      }));
  }
}
