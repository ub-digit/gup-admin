interface PublicationCompareRow {
  diff: boolean;
  display_label: string;
  display_type: string;
  first:
    | String
    | Author
    | Title
    | Sourceissue_sourcepages_sourcevolume
    | Url
    | Meta;
  second?:
    | String
    | Author
    | Title
    | Sourceissue_sourcepages_sourcevolume
    | Url
    | Meta;
  visibility: string;
}

interface String {
  value: string;
}

interface Title {
  value: {
    title: string;
    url: string;
  };
}

interface Sourceissue_sourcepages_sourcevolume {
  value: {
    sourceissue: string;
    sourcepages: string;
    sourcevolume: string;
  };
}

interface Author {
  value: [
    {
      id?: number;
      name: string;
    },
  ];
}

interface Url {
  value: {
    display_title: string;
    url: string;
  };
}

interface Meta {
  value: {
    attended: boolean;
    created_at: string;
    source: string;
    updated_at: string;
    version_created_by: string;
    version_updated_by: string;
  };
}

export type { PublicationCompareRow };
