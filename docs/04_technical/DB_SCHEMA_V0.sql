-- Draft schema for the horizontal drill model.
-- Intended as an authoring/source-of-truth model; static JSON exports remain
-- the public runtime format for now.

CREATE TABLE nodes (
  id TEXT PRIMARY KEY,
  slug TEXT NOT NULL UNIQUE,
  type TEXT NOT NULL,
  label TEXT NOT NULL,
  label_he TEXT,
  summary_short TEXT,
  summary_long TEXT,
  sort_order INTEGER,
  importance INTEGER,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE node_edges (
  id TEXT PRIMARY KEY,
  source_node_id TEXT NOT NULL REFERENCES nodes(id),
  target_node_id TEXT NOT NULL REFERENCES nodes(id),
  relation_type TEXT NOT NULL,
  sort_order INTEGER,
  weight INTEGER,
  metadata_json TEXT,
  UNIQUE(source_node_id, target_node_id, relation_type)
);

CREATE INDEX idx_node_edges_source ON node_edges(source_node_id);
CREATE INDEX idx_node_edges_target ON node_edges(target_node_id);
CREATE INDEX idx_node_edges_relation ON node_edges(relation_type);

CREATE TABLE source_refs (
  id TEXT PRIMARY KEY,
  node_id TEXT NOT NULL REFERENCES nodes(id),
  source_system TEXT NOT NULL DEFAULT 'sefaria',
  book_name TEXT NOT NULL,
  ref_start TEXT NOT NULL,
  ref_end TEXT,
  ref_display TEXT NOT NULL,
  chapter_start INTEGER,
  verse_start INTEGER,
  chapter_end INTEGER,
  verse_end INTEGER
);

CREATE INDEX idx_source_refs_node ON source_refs(node_id);
CREATE INDEX idx_source_refs_book ON source_refs(book_name);

CREATE TABLE time_ranges (
  id TEXT PRIMARY KEY,
  node_id TEXT NOT NULL REFERENCES nodes(id),
  calendar TEXT NOT NULL,
  start_value INTEGER,
  end_value INTEGER,
  certainty TEXT,
  label TEXT
);

CREATE INDEX idx_time_ranges_node ON time_ranges(node_id);
CREATE INDEX idx_time_ranges_calendar ON time_ranges(calendar, start_value, end_value);

CREATE TABLE visual_markers (
  id TEXT PRIMARY KEY,
  node_id TEXT NOT NULL REFERENCES nodes(id),
  marker_type TEXT NOT NULL,
  icon TEXT,
  asset_path TEXT,
  caption TEXT,
  lane TEXT,
  color TEXT,
  importance INTEGER
);

CREATE INDEX idx_visual_markers_node ON visual_markers(node_id);

CREATE TABLE view_projections (
  id TEXT PRIMARY KEY,
  view_key TEXT NOT NULL,
  node_id TEXT NOT NULL REFERENCES nodes(id),
  parent_node_id TEXT REFERENCES nodes(id),
  display_mode TEXT,
  sort_order INTEGER,
  metadata_json TEXT
);

CREATE INDEX idx_view_projections_view ON view_projections(view_key, sort_order);
CREATE INDEX idx_view_projections_node ON view_projections(node_id);
