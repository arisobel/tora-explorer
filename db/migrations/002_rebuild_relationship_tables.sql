PRAGMA foreign_keys = OFF;

DROP INDEX IF EXISTS idx_node_edges_source;
DROP INDEX IF EXISTS idx_node_edges_target;
DROP INDEX IF EXISTS idx_node_edges_relation;
DROP INDEX IF EXISTS idx_source_refs_node;
DROP INDEX IF EXISTS idx_source_refs_book;
DROP INDEX IF EXISTS idx_source_refs_display;
DROP INDEX IF EXISTS idx_time_ranges_node;
DROP INDEX IF EXISTS idx_time_ranges_calendar;
DROP INDEX IF EXISTS idx_visual_markers_node;
DROP INDEX IF EXISTS idx_visual_markers_lane;
DROP INDEX IF EXISTS idx_view_projections_view;
DROP INDEX IF EXISTS idx_view_projections_node;
DROP INDEX IF EXISTS idx_view_projections_parent;

ALTER TABLE node_edges RENAME TO node_edges_old;
CREATE TABLE node_edges (
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
INSERT INTO node_edges SELECT * FROM node_edges_old;
DROP TABLE node_edges_old;
CREATE INDEX idx_node_edges_source ON node_edges(source_node_id);
CREATE INDEX idx_node_edges_target ON node_edges(target_node_id);
CREATE INDEX idx_node_edges_relation ON node_edges(relation_type);

ALTER TABLE source_refs RENAME TO source_refs_old;
CREATE TABLE source_refs (
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
INSERT INTO source_refs SELECT * FROM source_refs_old;
DROP TABLE source_refs_old;
CREATE INDEX idx_source_refs_node ON source_refs(node_id);
CREATE INDEX idx_source_refs_book ON source_refs(book_name);
CREATE INDEX idx_source_refs_display ON source_refs(ref_display);

ALTER TABLE time_ranges RENAME TO time_ranges_old;
CREATE TABLE time_ranges (
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
INSERT INTO time_ranges SELECT * FROM time_ranges_old;
DROP TABLE time_ranges_old;
CREATE INDEX idx_time_ranges_node ON time_ranges(node_id);
CREATE INDEX idx_time_ranges_calendar ON time_ranges(calendar, start_value, end_value);

ALTER TABLE visual_markers RENAME TO visual_markers_old;
CREATE TABLE visual_markers (
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
INSERT INTO visual_markers SELECT * FROM visual_markers_old;
DROP TABLE visual_markers_old;
CREATE INDEX idx_visual_markers_node ON visual_markers(node_id);
CREATE INDEX idx_visual_markers_lane ON visual_markers(lane);

ALTER TABLE view_projections RENAME TO view_projections_old;
CREATE TABLE view_projections (
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
INSERT INTO view_projections SELECT * FROM view_projections_old;
DROP TABLE view_projections_old;
CREATE INDEX idx_view_projections_view ON view_projections(view_key, sort_order);
CREATE INDEX idx_view_projections_node ON view_projections(node_id);
CREATE INDEX idx_view_projections_parent ON view_projections(parent_node_id);

PRAGMA foreign_keys = ON;

INSERT OR IGNORE INTO schema_migrations(version) VALUES ('002_rebuild_relationship_tables');
