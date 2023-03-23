#model with a list of publication types

defmodule GupAdmin.Model.PublicationType do
  def publication_types do
    [
      %{
        "publication_type_code" => "other",
        "publication_type_id" => 21,
        "publication_type_label" => "Annan publikation"
      },
      %{
        "publication_type_code" => "publication_newspaper-article",
        "publication_type_id" => 42,
        "publication_type_label" => "Artikel i dagstidning"
      },
      %{
        "publication_type_code" => "publication_journal-article",
        "publication_type_id" => 5,
        "publication_type_label" => "Artikel i vetenskaplig tidskrift"
      },
      %{
        "publication_type_code" => "publication_magazine-article",
        "publication_type_id" => 7,
        "publication_type_label" => "Artikel i övriga tidskrifter"
      },
      %{
        "publication_type_code" => "publication_encyclopedia-entry",
        "publication_type_id" => 43,
        "publication_type_label" => "Bidrag till encyklopedi"
      },
      %{
        "publication_type_code" => "publication_book",
        "publication_type_id" => 9,
        "publication_type_label" => "Bok"
      },
      %{
        "publication_type_code" => "publication_doctoral-thesis",
        "publication_type_id" => 17,
        "publication_type_label" => "Doktorsavhandling"
      },
      %{
        "publication_type_code" => "publication_review-article",
        "publication_type_id" => 22,
        "publication_type_label" => "Forskningsöversiktsartikel (Review article)"
      },
      %{
        "publication_type_code" => "publication_editorial-letter",
        "publication_type_id" => 40,
        "publication_type_label" => "Inledande text i tidskrift"
      },
      %{
        "publication_type_code" => "publication_book-chapter",
        "publication_type_id" => 10,
        "publication_type_label" => "Kapitel i bok"
      },
      %{
        "publication_type_code" => "publication_report-chapter",
        "publication_type_id" => 41,
        "publication_type_label" => "Kapitel i rapport"
      },
      %{
        "publication_type_code" => "conference_other",
        "publication_type_id" => 1,
        "publication_type_label" => "Konferensbidrag (offentliggjort, men ej förlagsutgivet)"
      },
      %{
        "publication_type_code" => "artistic-work_original-creative-work",
        "publication_type_id" => 34,
        "publication_type_label" => "Konstnärligt arbete"
      },
      %{
        "publication_type_code" => "artistic-work_scientific_and_development",
        "publication_type_id" => 23,
        "publication_type_label" => "Konstnärligt forsknings- och utvecklingsarbete"
      },
      %{
        "publication_type_code" => "publication_licentiate-thesis",
        "publication_type_id" => 19,
        "publication_type_label" => "Licentiatsavhandling"
      },
      %{
        "publication_type_code" => "publication_textbook",
        "publication_type_id" => 30,
        "publication_type_label" => "Lärobok"
      },
      %{
        "publication_type_code" => "conference_paper",
        "publication_type_id" => 2,
        "publication_type_label" => "Paper i proceeding"
      },
      %{
        "publication_type_code" => "intellectual-property_patent",
        "publication_type_id" => 13,
        "publication_type_label" => "Patent"
      },
      %{
        "publication_type_code" => "conference_poster",
        "publication_type_id" => 3,
        "publication_type_label" => "Poster (konferens)"
      },
      %{
        "publication_type_code" => "conference_proceeding",
        "publication_type_id" => 45,
        "publication_type_label" => "Proceeding (red.)"
      },
      %{
        "publication_type_code" => "publication_report",
        "publication_type_id" => 16,
        "publication_type_label" => "Rapport"
      },
      %{
        "publication_type_code" => "publication_book-review",
        "publication_type_id" => 18,
        "publication_type_label" => "Recension"
      },
      %{
        "publication_type_code" => "publication_edited-book",
        "publication_type_id" => 8,
        "publication_type_label" => "Samlingsverk (red.)"
      },
      %{
        "publication_type_code" => "publication_journal-issue",
        "publication_type_id" => 44,
        "publication_type_label" => "Special / temanummer av tidskrift (red.)"
      },
      %{
        "publication_type_code" => "publication_textcritical-edition",
        "publication_type_id" => 28,
        "publication_type_label" => "Textkritisk utgåva"
      },
      %{
        "publication_type_code" => "publication_working-paper",
        "publication_type_id" => 46,
        "publication_type_label" => "Working paper"
      }
    ]
  end
end
