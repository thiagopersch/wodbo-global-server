//! Persistent settings (`%APPDATA%/PeixolaMapEditor/peixola.toml`).

use std::path::{Path, PathBuf};

use serde::{Deserialize, Serialize};

use crate::i18n::Lang;

#[derive(Clone, Serialize, Deserialize)]
#[serde(default)]
pub struct Paths {
    /// Server `data` folder (items/, monster/, npc/, world/).
    pub server_data: PathBuf,
    /// Folder with Tibia.dat / Tibia.spr / Tibia.otfi.
    pub client_things: PathBuf,
    /// RME materials.xml (borders, grounds, walls, doodads, tilesets).
    pub materials_xml: PathBuf,
    /// Extra materials folder (RME extensions).
    pub extensions_dir: PathBuf,
}

impl Default for Paths {
    fn default() -> Self {
        detect_paths().unwrap_or(Self {
            server_data: PathBuf::new(),
            client_things: PathBuf::new(),
            materials_xml: PathBuf::new(),
            extensions_dir: PathBuf::new(),
        })
    }
}

impl Paths {
    pub fn items_otb(&self) -> PathBuf {
        self.server_data.join("items/items.otb")
    }
    pub fn items_xml(&self) -> PathBuf {
        self.server_data.join("items/items.xml")
    }
    pub fn dat(&self) -> PathBuf {
        self.client_things.join("Tibia.dat")
    }
    pub fn spr(&self) -> PathBuf {
        self.client_things.join("Tibia.spr")
    }
    pub fn otfi(&self) -> PathBuf {
        self.client_things.join("Tibia.otfi")
    }

    /// First missing required file, if any.
    pub fn missing(&self) -> Option<PathBuf> {
        [self.items_otb(), self.items_xml(), self.dat(), self.spr(), self.materials_xml.clone()].into_iter().find(|p| !p.is_file())
    }
}

/// Look for the OTServer layout (`server/data`, `cliente/data/things/860`, `server/RME`)
/// around the executable and the working directory.
fn detect_paths() -> Option<Paths> {
    let mut starts: Vec<PathBuf> = Vec::new();
    if let Ok(exe) = std::env::current_exe() {
        starts.push(exe);
    }
    if let Ok(cwd) = std::env::current_dir() {
        starts.push(cwd);
    }
    for start in starts {
        for dir in start.ancestors() {
            for server in [dir.to_path_buf(), dir.join("server")] {
                if server.join("data/items/items.otb").is_file() {
                    let things = server.join("../cliente/data/things/860");
                    return Some(Paths {
                        server_data: clean(server.join("data")),
                        client_things: clean(things),
                        materials_xml: clean(server.join("RME/data/860/materials.xml")),
                        extensions_dir: clean(server.join("RME/extensions")),
                    });
                }
            }
        }
    }
    None
}

fn clean(p: PathBuf) -> PathBuf {
    p.canonicalize().map(|c| PathBuf::from(c.to_string_lossy().trim_start_matches(r"\\?\"))).unwrap_or(p)
}

#[derive(Clone, Serialize, Deserialize)]
#[serde(default)]
pub struct View {
    pub show_all_floors: bool,
    pub show_shade: bool,
    pub show_zones: bool,
    pub show_houses: bool,
    pub show_spawns: bool,
    pub show_creatures: bool,
    pub show_grid: bool,
    pub show_waypoints: bool,
    pub show_blocking: bool,
    pub highlight_items: bool,
    pub show_animation: bool,
    pub show_lights: bool,
    /// HD Mode: sprites upscaled 32 -> 64 px with xBRZ, like the client's `hdSprites`.
    pub hd_sprites: bool,
    /// Ambient light 0 (night) ..= 255 (day) used by the light preview.
    pub ambient_light: u8,
}

impl Default for View {
    fn default() -> Self {
        Self {
            show_all_floors: true,
            show_shade: true,
            show_zones: true,
            show_houses: true,
            show_spawns: true,
            show_creatures: true,
            show_grid: false,
            show_waypoints: true,
            show_blocking: false,
            highlight_items: false,
            show_animation: true,
            show_lights: false,
            hd_sprites: false,
            ambient_light: 90,
        }
    }
}

#[derive(Clone, Serialize, Deserialize)]
#[serde(default)]
pub struct Settings {
    pub lang: Lang,
    pub paths: Paths,
    pub view: View,
    pub recent: Vec<PathBuf>,
    pub auto_border: bool,
    pub eraser_leave_unique: bool,
    pub house_brush_remove_items: bool,
    pub default_spawn_time: u32,
    /// Direction of newly placed creatures: 0 N, 1 E, 2 S, 3 W.
    pub default_direction: u8,
    pub undo_limit: usize,
    pub open_last_map: bool,
    /// Sprite animation speed: milliseconds per frame (50..=500).
    pub anim_ms: u32,
    /// Creatures hidden from the palette ("npc:Name" / "monster:Name").
    pub hidden_creatures: Vec<String>,
}

impl Default for Settings {
    fn default() -> Self {
        Self {
            lang: Lang::Pt,
            paths: Paths::default(),
            view: View::default(),
            recent: Vec::new(),
            auto_border: true,
            eraser_leave_unique: true,
            house_brush_remove_items: false,
            default_spawn_time: 60,
            default_direction: 2,
            undo_limit: 500,
            open_last_map: false,
            anim_ms: 100,
            hidden_creatures: Vec::new(),
        }
    }
}

fn settings_path() -> PathBuf {
    let base = std::env::var_os("APPDATA").map(PathBuf::from).unwrap_or_else(|| PathBuf::from("."));
    base.join("PeixolaMapEditor").join("peixola.toml")
}

impl Settings {
    pub fn load() -> Self {
        let p = settings_path();
        std::fs::read_to_string(&p).ok().and_then(|s| toml::from_str(&s).ok()).unwrap_or_default()
    }

    pub fn save(&self) {
        let p = settings_path();
        if let Some(dir) = p.parent() {
            let _ = std::fs::create_dir_all(dir);
        }
        if let Ok(s) = toml::to_string_pretty(self) {
            let _ = std::fs::write(p, s);
        }
    }

    pub fn push_recent(&mut self, path: &Path) {
        self.recent.retain(|p| p != path);
        self.recent.insert(0, path.to_path_buf());
        self.recent.truncate(10);
    }
}
