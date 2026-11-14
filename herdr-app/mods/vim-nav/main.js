// vim-nav: ctrl-h/j/k/l moves between Herdr panes and vim splits, like
// vim-tmux-navigator. keys.json binds them to `vim-nav.<direction>`. When the
// focused terminal runs vim, nvim or fzf, the chord is pressed into it with
// `hc keys`; nvim walks its own splits and runs `herdr-app do pane.go` at the
// edge (nvim/after/plugin/mux_nav.lua). Anything else moves pane focus here.
//
// `<mod>.<command>` only reaches a copy on screen, so the personal layout hosts
// this as a floating block. It renders nothing, and Herdr frames no empty float.

import { View, div } from "gpui-kit";
import { focused, hc, nextCommand, panes, run, terminals } from "herdr";

const CHORD = { left: "ctrl+h", down: "ctrl+j", up: "ctrl+k", right: "ctrl+l" };

// vi, vim, nvim, view, vimdiff, gvim, vimx..., plus fzf, which uses ctrl-j/k itself.
const VIM = /^(g?(view|n?vim?x?)(diff)?|fzf)$/;

const isVim = (program) =>
  !!program && (VIM.test(program.key) || VIM.test(String(program.name ?? "").toLowerCase()));

export default class VimNav extends View {
  init(_props, cx) {
    // One command at a time, so each press of a held key sees where the last one left focus.
    cx.spawn(async (cx) => {
      for (;;) {
        const dir = await nextCommand();
        try {
          await this.go(dir);
        } catch (e) {
          console.log(`vim-nav ${dir}: ${e}`);
        }
        cx.notify();
      }
    });
  }

  async go(dir) {
    const chord = CHORD[dir];
    const f = focused();
    if (!chord || !f) return;
    // `shown` is a terminal.show stand-in: what's actually on screen in that pane.
    const address = f.shown ?? f.terminal;
    const program =
      terminals().find((t) => t.address === address)?.program ??
      panes().find((p) => p.pane === f.pane)?.program;
    if (address && isVim(program)) await hc(["keys", address, chord]);
    else run("pane.go", { direction: dir });
  }

  render() {
    return div();
  }
}
