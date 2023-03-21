#model with a list of publication types

defmodule GupAdmin.Model.PublicationType do
  def publication_types do
    [
      %{
        "publications_type_id" => 1,
        "publications_type_label" => "conference_other"
      },
      %{
        "publications_type_id" => 2,
        "publications_type_label" => "conference_paper"
      },
      %{
        "publications_type_id" => 3,
        "publications_type_label" => "conference_poster"
      },
      %{
        "publications_type_id" => 5,
        "publications_type_label" => "publication_journal-article"
      },
      %{
        "publications_type_id" => 7,
        "publications_type_label" => "publication_magazine-article"
      },
      %{
        "publications_type_id" => 8,
        "publications_type_label" => "publication_edited-book"
      },
      %{
        "publications_type_id" => 9,
        "publications_type_label" => "publication_book"
      },
      %{
        "publications_type_id" => 10,
        "publications_type_label" => "publication_book-chapter"
      },
      %{
        "publications_type_id" => 13,
        "publications_type_label" => "intellectual-property_patent"
      },
      %{
        "publications_type_id" => 16,
        "publications_type_label" => "publication_report"
      },
      %{
        "publications_type_id" => 17,
        "publications_type_label" => "publication_doctoral-thesis"
      },
      %{
        "publications_type_id" => 18,
        "publications_type_label" => "publication_book-review"
      },
      %{
        "publications_type_id" => 19,
        "publications_type_label" => "publication_licentiate-thesis"
      },
      %{"publications_type_id" => 21, "publications_type_label" => "other"},
      %{
        "publications_type_id" => 22,
        "publications_type_label" => "publication_review-article"
      },
      %{
        "publications_type_id" => 23,
        "publications_type_label" => "artistic-work_scientific_and_development"
      },
      %{
        "publications_type_id" => 28,
        "publications_type_label" => "publication_textcritical-edition"
      },
      %{
        "publications_type_id" => 30,
        "publications_type_label" => "publication_textbook"
      },
      %{
        "publications_type_id" => 34,
        "publications_type_label" => "artistic-work_original-creative-work"
      },
      %{
        "publications_type_id" => 40,
        "publications_type_label" => "publication_editorial-letter"
      },
      %{
        "publications_type_id" => 41,
        "publications_type_label" => "publication_report-chapter"
      },
      %{
        "publications_type_id" => 42,
        "publications_type_label" => "publication_newspaper-article"
      },
      %{
        "publications_type_id" => 43,
        "publications_type_label" => "publication_encyclopedia-entry"
      },
      %{
        "publications_type_id" => 44,
        "publications_type_label" => "publication_journal-issue"
      },
      %{
        "publications_type_id" => 45,
        "publications_type_label" => "conference_proceeding"
      },
      %{
        "publications_type_id" => 46,
        "publications_type_label" => "publication_working-paper"
      }
    ]
  end
end
