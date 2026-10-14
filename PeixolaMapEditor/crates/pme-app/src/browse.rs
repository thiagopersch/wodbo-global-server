//! "Browse field" (RME): window listing every object on one tile. Selecting one enables
//! "Select RAW" / "Select brush" / "Properties".

use eframe::egui::{self, Color32, RichText, Sense, Vec2};
use pme_core::position::Position;

use crate::app::App;
use crate::i18n::t;
use crate::properties::PropTarget;
use crate::view;

#[derive(Clone, Copy, PartialEq, Debug)]
pub enum BrowseSel {
    /// 0 = ground, n = `items[n - 1]`.
    Item(usize),
    Creature,
}

pub struct BrowseField {
    pub pos: Position,
    pub sel: Option<BrowseSel>,
}

enum Action {
    Raw(u16),
    Brush(pme_core::materials::BrushId),
    Props(PropTarget),
    Goto,
}

impl App {
    pub fn browse_field_window(&mut self, ctx: &egui::Context) {
        let Some(mut bf) = self.browse.take() else { return };
        let frame = self.anim_frame(ctx);
        let mut open = true;
        let mut action = None;
        let (Some(ed), Some(a), Some(atlas)) = (&self.editor, &self.assets, &mut self.atlas) else {
            self.browse = Some(bf);
            return;
        };
        // Re-read the tile every frame so undo/edits are reflected.
        let tile = ed.map.get(bf.pos).cloned().unwrap_or_default();
        egui::Window::new(format!("{} — {}", t("browse-title"), bf.pos)).id(egui::Id::new("browse-field")).open(&mut open).default_width(340.0).resizable(true).show(ctx, |ui| {
            // Rows: creature, items top → bottom, ground.
            let mut rows: Vec<(BrowseSel, String, Option<u16>)> = Vec::new();
            if let Some(c) = &tile.creature {
                rows.push((BrowseSel::Creature, format!("{} ({})", c.name, if c.is_npc { "NPC" } else { t("creatures-monsters") }), None));
            }
            for (i, it) in tile.items.iter().enumerate().rev() {
                rows.push((BrowseSel::Item(i + 1), format!("{} [{}]", a.db.name(it.id), it.id), Some(it.id)));
            }
            if let Some(g) = &tile.ground {
                rows.push((BrowseSel::Item(0), format!("{} [{}]  ({})", a.db.name(g.id), g.id, t("props-ground")), Some(g.id)));
            }
            if rows.is_empty() {
                ui.label(RichText::new(t("props-empty")).weak());
            }
            egui::ScrollArea::vertical().max_height(360.0).auto_shrink([false, true]).show(ui, |ui| {
                for (sel, label, id) in &rows {
                    let (rect, resp) = ui.allocate_exact_size(Vec2::new(ui.available_width(), 34.0), Sense::click());
                    let selected = bf.sel == Some(*sel);
                    if selected || resp.hovered() {
                        ui.painter().rect_filled(rect, 3.0, if selected { Color32::from_rgb(40, 110, 170) } else { Color32::from_gray(50) });
                    }
                    let icon = egui::Rect::from_min_size(rect.min + Vec2::splat(1.0), Vec2::splat(32.0));
                    match (sel, id) {
                        (_, Some(id)) => view::paint_item_icon(ctx, ui.painter(), atlas, &a.db, *id, icon, frame),
                        (BrowseSel::Creature, None) => {
                            if let Some(c) = &tile.creature {
                                view::paint_creature_icon(ctx, ui.painter(), atlas, a, &c.name, c.is_npc, c.direction, icon, frame);
                            }
                        }
                        _ => {}
                    }
                    // Extra info (aid / uid / text) on the right of the name.
                    let mut extra = String::new();
                    if let BrowseSel::Item(k) = sel {
                        let it = if *k == 0 { tile.ground.as_ref() } else { tile.items.get(k - 1) };
                        if let Some(it) = it {
                            if it.action_id() > 0 {
                                extra.push_str(&format!("  aid {}", it.action_id()));
                            }
                            if it.unique_id() > 0 {
                                extra.push_str(&format!("  uid {}", it.unique_id()));
                            }
                        }
                    }
                    ui.painter().text(egui::pos2(rect.min.x + 40.0, rect.center().y), egui::Align2::LEFT_CENTER, format!("{label}{extra}"), egui::FontId::proportional(13.0), ui.visuals().text_color());
                    if resp.clicked() {
                        bf.sel = Some(*sel);
                    }
                    if resp.double_clicked() {
                        action = Some(Action::Props(match sel {
                            BrowseSel::Item(k) => PropTarget::Item(*k),
                            BrowseSel::Creature => PropTarget::Creature,
                        }));
                    }
                }
            });
            ui.separator();
            // Buttons for the selected object.
            let sel_item = match bf.sel {
                Some(BrowseSel::Item(k)) => if k == 0 { tile.ground.as_ref() } else { tile.items.get(k - 1) }.map(|i| i.id),
                _ => None,
            };
            let brush = sel_item.and_then(|id| {
                let info = a.mat.info(id);
                [info.brush, info.doodad].into_iter().find(|&b| b != 0 && a.mat.brush(b).is_some())
            });
            ui.horizontal_wrapped(|ui| {
                if ui.add_enabled(sel_item.is_some(), egui::Button::new(t("ctx-select-raw"))).clicked() {
                    action = sel_item.map(Action::Raw);
                }
                let brush_label = brush.and_then(|b| a.mat.brush(b)).map(|d| format!("{}: {}", t("ctx-select-brush"), d.name)).unwrap_or_else(|| t("ctx-select-brush").to_owned());
                if ui.add_enabled(brush.is_some(), egui::Button::new(brush_label)).clicked() {
                    action = brush.map(Action::Brush);
                }
                if ui.add_enabled(bf.sel.is_some(), egui::Button::new(t("ctx-properties"))).clicked() {
                    action = bf.sel.map(|s| {
                        Action::Props(match s {
                            BrowseSel::Item(k) => PropTarget::Item(k),
                            BrowseSel::Creature => PropTarget::Creature,
                        })
                    });
                }
                if ui.button(t("goto-go")).clicked() {
                    action = Some(Action::Goto);
                }
            });
        });
        match action {
            Some(Action::Raw(id)) => self.select_raw_in_palette(id),
            Some(Action::Brush(b)) => self.select_brush_in_palette(b),
            Some(Action::Props(target)) => self.open_properties(bf.pos, target),
            Some(Action::Goto) => self.goto(bf.pos),
            None => {}
        }
        if open {
            self.browse = Some(bf);
        }
    }
}
