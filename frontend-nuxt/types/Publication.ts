interface Identifier {
  identifier_code: string;
  identifier_value: string;
}
interface Author {
  id: number;
  name: string;
}
interface Publication {
  publication_type_id: number | null;
  publisher: string | null;
  title: string | null;
  abstract: string | null;
  place: string | null;
  id: string;
  sourceissue: string | null;
  deleted: boolean;
  sourcepages: string | null;
  epub_ahead_of_print: string | null;
  url: string | null;
  current_version_id: number;
  updated_at: string;
  created_at: string;
  isbn: string | null;
  source: string | null;
  issn: string | null;
  version_updated_at: string;
  sourcevolume: string | null;
  publication_identifiers: Identifier[] | null;
  authors: Author[] | null;
  deleted_at: string | null;
  article_number: string | null;
  version_created_at: string;
  published_at: string;
  eissn: string;
  publication_type_label: string;
  pubyear: number;
  sourcetitle: string;
  version_updated_by: string;
  keywords: string | null;
  attended: boolean;
  publication_id: number;
  journal_id: string | null;
  origin_id: string | null;
  publanguage: string | null;
  ref_value: string | null;
  extent: string | null;
  version_created_by: string | null;
  alt_title: string | null;
}

export type { Publication, Identifier, Author };
