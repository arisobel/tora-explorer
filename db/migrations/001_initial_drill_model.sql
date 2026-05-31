PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS schema_migrations (
  version TEXT PRIMARY KEY,
  applied_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS nodes (
  id TEXT PRIMARY KEY,
  slug TEXT NOT NULL UNIQUE,
  type TEXT NOT NULL CHECK (type IN (
    'tradition',
    'corpus',
    'book',
    'era',
    'timeline_phase',
    'timeline_event',
    'milestone',
    'parasha',
    'fact',
    'character',
    'theme',
    'place',
    'source_ref',
    'visual_marker',
    'asset',
    'mishna_order',
    'tractate',
    'sugya',
    'halacha_topic',
    'commentary'
  )),
  label TEXT NOT NULL,
  label_he TEXT,
  summary_short TEXT,
  summary_long TEXT,
  sort_order INTEGER,
  importance INTEGER CHECK (importance IS NULL OR importance BETWEEN 1 AND 5),
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_nodes_type ON nodes(type);
CREATE INDEX IF NOT EXISTS idx_nodes_sort ON nodes(type, sort_order);

CREATE TABLE IF NOT EXISTS node_edges (
  id TEXT PRIMARY KEY,
  source_node_id TEXT NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
  target_node_id TEXT NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
  relation_type TEXT NOT NULL CHECK (relation_type IN (
    'contains',
    'aggregates',
    'appears_in',
    'tagged_with',
    'located_in',
    'precedes',
    'related_to',
    'opens',
    'has_source',
    'has_visual'
  )),
  sort_order INTEGER,
  weight INTEGER,
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(source_node_id, target_node_id, relation_type)
);

CREATE INDEX IF NOT EXISTS idx_node_edges_source ON node_edges(source_node_id);
CREATE INDEX IF NOT EXISTS idx_node_edges_target ON node_edges(target_node_id);
CREATE INDEX IF NOT EXISTS idx_node_edges_relation ON node_edges(relation_type);

CREATE TABLE IF NOT EXISTS source_refs (
  id TEXT PRIMARY KEY,
  node_id TEXT NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
  source_system TEXT NOT NULL DEFAULT 'sefaria',
  book_name TEXT NOT NULL,
  ref_start TEXT NOT NULL,
  ref_end TEXT,
  ref_display TEXT NOT NULL,
  chapter_start INTEGER,
  verse_start INTEGER,
  chapter_end INTEGER,
  verse_end INTEGER,
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_source_refs_node ON source_refs(node_id);
CREATE INDEX IF NOT EXISTS idx_source_refs_book ON source_refs(book_name);
CREATE INDEX IF NOT EXISTS idx_source_refs_display ON source_refs(ref_display);

CREATE TABLE IF NOT EXISTS time_ranges (
  id TEXT PRIMARY KEY,
  node_id TEXT NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
  calendar TEXT NOT NULL CHECK (calendar IN ('anno_mundi', 'ce', 'bce')),
  start_value INTEGER,
  end_value INTEGER,
  certainty TEXT CHECK (certainty IS NULL OR certainty IN ('traditional', 'approximate', 'unknown')),
  label TEXT,
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_time_ranges_node ON time_ranges(node_id);
CREATE INDEX IF NOT EXISTS idx_time_ranges_calendar ON time_ranges(calendar, start_value, end_value);

CREATE TABLE IF NOT EXISTS visual_markers (
  id TEXT PRIMARY KEY,
  node_id TEXT NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
  marker_type TEXT NOT NULL CHECK (marker_type IN ('icon', 'image', 'symbol', 'map', 'color')),
  icon TEXT,
  asset_path TEXT,
  caption TEXT,
  lane TEXT,
  color TEXT,
  importance INTEGER CHECK (importance IS NULL OR importance BETWEEN 1 AND 5),
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (asset_path IS NULL OR caption IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_visual_markers_node ON visual_markers(node_id);
CREATE INDEX IF NOT EXISTS idx_visual_markers_lane ON visual_markers(lane);

CREATE TABLE IF NOT EXISTS view_projections (
  id TEXT PRIMARY KEY,
  view_key TEXT NOT NULL,
  node_id TEXT NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
  parent_node_id TEXT REFERENCES nodes(id) ON DELETE SET NULL,
  display_mode TEXT CHECK (display_mode IS NULL OR display_mode IN (
    'band',
    'card',
    'chip',
    'drawer_item',
    'lane_marker',
    'list_item',
    'ruler_segment'
  )),
  sort_order INTEGER,
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(view_key, node_id, parent_node_id, display_mode)
);

CREATE INDEX IF NOT EXISTS idx_view_projections_view ON view_projections(view_key, sort_order);
CREATE INDEX IF NOT EXISTS idx_view_projections_node ON view_projections(node_id);
CREATE INDEX IF NOT EXISTS idx_view_projections_parent ON view_projections(parent_node_id);

INSERT OR IGNORE INTO schema_migrations(version) VALUES ('001_initial_drill_model');
