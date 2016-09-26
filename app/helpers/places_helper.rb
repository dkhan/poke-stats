module PlacesHelper
  HOME = [
    [42.673136638556706,-71.14341265037436, "Enmore St"], # EEVEE
    [42.671908980549155,-71.1379352968859, "Olde Berry Rd - S"],
    [42.67310580146113,-71.13802813401412, "Olde Berry Rd - N"], # DRATINI
    #[42.67190376384465,-71.13747111091996, "Olde Berry Rd 1"],
    [42.67350702447055,-71.13171516000095, "YMCA"], # MACHOKE
    [42.67377589019432,-71.13199367566865, "YMCA - N"], # GROWLITHE
    [42.67244721093195,-71.13329341287951, "YMCA - W"], # SQUIRTLE
    #[42.67202538324983,-71.13385044181574, "YMCA - W"], # SQUIRTLE
    [42.672494, -71.131730, "YMCA - SE"], # BULBASAUR
    #[42.67230482444437,-71.13375760371375, "YMCA - W"], # SQUIRTLE
    #[42.67348064940073,-71.13199367566865, "YMCA"], # DRATINI
    #[42.67312215978564,-71.13162232140185, "YMCA"], # DRATINI
    #[42.67340159017563,-71.13152948278112, "YMCA"], # DRAGONAIR
    #[42.673285593123396,-71.13171516000095, "YMCA"], # SQUIRTLE
    [42.685162329682996,-71.13644989988968, "Market Basket 1"], # SQUIRTLE
    [42.673285593123396,-71.13171516000095, "Market Basket 2"], # SQUIRTLE
    [42.68319619689961,-71.13617138733596, "Market Basket 3"], # DRATINI
    [42.68499893120908,-71.13635706239342, "Market Basket 4"], # LAPRAS
    #[42.68416080320546,-71.13663557481728, "Market Basket"], # SQUIRTLE
    [42.66499492351381,-71.14545503404499, "Stop & Shop - NW"], # DRATINI
    [42.665147, -71.144501, "Stop & Shop"], # SQUIRTLE
    [42.66506903839802,-71.14415533656101, "Stop & Shop/Citizens Bank"], # BULBASAUR
    #[42.66474701354118,-71.14573354009505, "Stop & Shop"], # DRATINI
    [42.664243, -71.145270, "Sovereign Bank"], # LAPRAS
    [42.663513215023904,-71.1449908568606, "McDonald's 1"], # SQUIRTLE
    [42.66384558670499,-71.14434100789065, "McDonald's 2"], # SQUIRTLE
    [42.663270763489955,-71.14443384352289, "McDonald's 3"], # GROWLITHE
    [42.66312310676206,-71.14443384352289, "McDonald's 4"], # GROWLITHE
    #[42.66375078772145,-71.14378399364129, "Papa Gino's"], # EEVEE
    [42.661277362484604,-71.14443384352289, "Whole Foods 1"], # SQUIRTLE
    [42.661572685946744,-71.14443384352289, "Whole Foods 2"], # GROWLITHE
    [42.661324445342316,-71.14601204594967, "Whole Foods 3"], # DRATINI
    [42.661103266475465,-71.14471235028944, "Whole Foods Entrance"], # SQUIRTLE
    [42.661960, -71.147573, "Post Office - W"], # GROWLITHE
    [42.662556, -71.146313, "Post Office - E"], # GROWLITHE
    [42.66301706074073,-71.14684756234064, "Post Office - N"], # DRATINI
    [42.65569323520369,-71.14025621859314, "TD Bank"], # SQUIRTLE
    [42.656120, -71.140365, "Bank of America"],
    [42.66292883939314,-71.14025621859314, "Walnut/Maple"], # CHARMANDER
    [42.656210356387355,-71.13895650410521, "Park - NW"], # GROWLITHE
    [42.65652669032813,-71.13951352512007, "Orange Leaf"], # LAPRAS
    [42.669708358324755,-71.14842575516631, "Main St/Park"], # DRAGONAIR
    [42.651427066663125,-71.13644989988968, "Main/Morton"], # BULBASAUR
    [42.66753654811314,-71.14564070476675, "Washington Park Dr - N"], # DRAGONAIR
    [42.666429197838504,-71.14564070476675, "Washington Park Dr"], # SQUIRTLE
    [42.665685783164896,-71.14517652779949, "Washington Park Dr - S"], # DRATINI
    [42.66653490557712,-71.14452667913346, "Washington Park Dr - E"], # DRATINI
    [42.64755096571303,-71.13190083713435, "Phillips Academy"], # BULBASAUR
    #[42.647661830191915,-71.13125096678935, "Phillips Academy"], # BULBASAUR
    [42.66768645467054,-71.12354528065349, "Merrimack College"], # SQUIRTLE
    [42.661777492118034,-71.16300053270632, "Chadwick Cir"], # SQUIRLTE
    #[42.66164052824874,-71.16262920746927, "Chadwick Cir"], # SQUIRLTE
    #[42.6618935988856,-71.16281487013148, "Chadwick Cir"], # SCYTHER
    [42.66399966253818,-71.15826610976004, "Cindy Ln"], # EXEGGCUTE
    [42.65864318991865,-71.15325312950287, "West Middle School"], # SCYTHER
    [42.656277867973294,-71.15975142503243, "Miles Cir"], # GROWLITHE
    [42.660195,-71.161008, "Leah Way"], # SNORLAX
    [42.650666,-71.176255, "Wild Rose Dr"], # SNORLAX
    [42.6674197,-71.1644858, "Andover Country Club"], # SNORLAX
    [42.6486060,-71.1824018, "IRS"], # SNORLAX
    [42.67201337194757,-71.14461951472231, "Argyle St"], # BULBASAUR
    [42.65141684779342,-71.15418146397418, "Indian Ridge Res"], # GROWLITHE
    [42.66041390090952,-71.13719259908058, "Elm St"], # DRATINI
    [42.661928104305005,-71.13134380547488, "Pine St"], # SQUIRTLE
  ].freeze

  WORK = [
    [42.344478, -71.034026, "Front"],
    [42.34470056212993,-71.03125131415162, "Mid"],
    [42.34481751970852,-71.02976552686681, "Here"],
    [42.344581, -71.027874, "Back"],
    [42.34334376219247,-71.02679393632243, "Police"],
    [42.3442827507186,-71.02447236640192, "Trucks"],
    [42.34329627280826,-71.02521527018891, "Get out"],
    [42.34449834627182,-71.03440859443437 , "Parking"],
    [42.344520292868566,-71.03106559103237 , "Mid-"],
    [42.34467919590425,-71.03199420579584 , "Mid-left"],
    [42.34434495616482,-71.03264423489141 , "Mid-left+"],
    [42.34690647275501,-71.03199420579584 , "Harpoon - NE"], # CHARMANDER
  ].freeze

  ELIZA = [
    [42.556519, -70.945009, "Office"],
    [42.558225, -70.942810, "Cemetery"],
    [42.559315, -70.940342, "Park"],
    [42.559826, -70.949958, "Baseball Field"],
    [42.551823, -70.941806, "Mall - Kohl's"],
    [42.552716, -70.938598, "Mall - Best Buy"],
    [42.553933, -70.940626, "Mall - Marshalls"],
  ].freeze

  CITY = [
    [42.661277362484604,-71.14443384352289, "Andover"], # Whole Foods
  ].freeze

  CASTLE = [
    [42.338598, -71.014065, "Parking"],
    [42.338812, -71.010429, "Fishing Pier"],
    [42.336751, -71.010139, "Lures"],
    [42.335097, -71.012290, "Lapras"],
    [42.337735, -71.012512, "Playground"],
    [42.330647, -71.015387, "Head Island"],

  ].freeze

  POINT = [
    [42.663513215023904,-71.1449908568606, "Point"],
  ].freeze
end
