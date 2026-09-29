-- Flexible organization relationship kinds: sanctioned + predecessor.
--
-- Forward-only enum extension. Both new directions keep the existing
-- parent-over-child semantics exposed by organization_ancestors:
--   * 'sanctioned'   – the parent organization sanctions/endorses the child
--                      (the sanctioning body reads as an ancestor of the
--                      sanctioned organization);
--   * 'predecessor'  – the parent organization is the historical predecessor
--                      of the child (lineage links the successor back to its
--                      origins).
--
-- The guarded upsert/end RPCs, the active-duplicate rule, the bilateral
-- admin-consent check, and cycle protection apply to every kind without any
-- function change because they operate on the enum type rather than a
-- hard-coded kind list.

alter type public.organization_relationship_kind add value 'sanctioned' after 'affiliate';
alter type public.organization_relationship_kind add value 'predecessor' after 'sanctioned';

comment on type public.organization_relationship_kind is
  'Directed relationship kinds between organizations: '
  'governs, recognizes, affiliate, sanctioned, predecessor.';