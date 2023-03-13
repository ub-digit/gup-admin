#model with a list of publication types

defmodule GupAdmin.Model.PublicationType do
  def publication_types do
    [
      %{"id" => 1, "display_name" => "Textkritisk utgåva"},
      %{"id" => 2, "display_name" => "Annan publikation"},
      %{"id" => 3, "display_name" => "Doktorsavhandling"},
      %{"id" => 4, "display_name" => "Rapport"},
      %{"id" => 5, "display_name" => "Paper i proceeding"},
      %{"id" => 6, "display_name" => "Konferensbidrag (offentliggjort, men ej förlagsutgivet)"},
      %{"id" => 7, "display_name" => "Samlingsverk (red.)"},
      %{"id" => 8, "display_name" => "Kapitel i rapport"},
      %{"id" => 9, "display_name" => "Artikel i dagstidning"},
      %{"id" => 10, "display_name" => "Bidrag till encyklopedi"},
      %{"id" => 11, "display_name" => "Licentiatsavhandling"},
      %{"id" => 12, "display_name" => "Special / temanummer av tidskrift (red.)"},
      %{"id" => 13, "display_name" => "Poster (konferens)"},
      %{"id" => 14, "display_name" => "Proceeding (red.)"},
      %{"id" => 15, "display_name" => "Patent"},
      %{"id" => 16, "display_name" => "Konstnärligt forsknings- och utvecklingsarbete"},
      %{"id" => 17, "display_name" => "Kapitel i bok"},
      %{"id" => 18, "display_name" => "Forskningsöversiktsartikel (Review article)"},
      %{"id" => 19, "display_name" => "Artikel i vetenskaplig tidskrift"},
      %{"id" => 20, "display_name" => "Inledande text i tidskrift"},
      %{"id" => 21, "display_name" => "Recension"},
      %{"id" => 22, "display_name" => "Artikel i övriga tidskrifter"},
      %{"id" => 23, "display_name" => "Bok"},
      %{"id" => 24, "display_name" => "Working paper"},
      %{"id" => 25, "display_name" => "Konstnärligt arbete"}
    ]
  end
end
