interface Identifier {
  identifier_code: string;
  identifier_value: string;
}
interface Author {
  id: number;
  name: string;
}
interface Publication {
  publication_type_id: number;
  publisher: string;
  title: string;
  abstract: string;
  place: string;
  id: string;
  sourceissue: string;
  deleted: boolean;
  sourcepages: string;
  epub_ahead_of_print: string;
  url: string;
  current_version_id: number;
  updated_at: string;
  created_at: string;
  isbn: string;
  source: string;
  issn: string;
  version_updated_at: string;
  sourcevolume: string;
  publication_identifiers: Identifier[];
  authors: Author[];
  deleted_at: string;
  article_number: string;
  version_created_at: string;
  published_at: string;
  eissn: string;
  publication_type_label: string;
  pubyear: number;
  sourcetitle: string;
  version_updated_by: string;
  keywords: string;
  attended: boolean;
  publication_id: number;
  journal_id: string;
  origin_id: string;
  publanguage: string;
  ref_value: string;
  extent: string;
  version_created_by: string;
  alt_title: string;
}

export type { Publication, Identifier, Author };
