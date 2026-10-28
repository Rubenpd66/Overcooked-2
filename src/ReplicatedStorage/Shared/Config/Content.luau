--!strict
-- Contenido original y reglas de composición declarativas.
local C = {}
C.Ingredients = {
 tomato={name="Tomate",en="Tomato",color=Color3.fromRGB(236,83,66),shape="ball"},
 leaf={name="Hoja",en="Leaf",color=Color3.fromRGB(96,171,111),shape="leaf"},
 mushroom={name="Seta",en="Mushroom",color=Color3.fromRGB(210,168,122),shape="cap"},
 grain={name="Grano",en="Grain",color=Color3.fromRGB(244,220,157),shape="grain"},
 dough={name="Masa",en="Dough",color=Color3.fromRGB(240,203,141),shape="ball"},
 berry={name="Baya",en="Berry",color=Color3.fromRGB(174,88,139),shape="ball"},
 cocoa={name="Cacao",en="Cocoa",color=Color3.fromRGB(112,69,54),shape="cube"},
 bean={name="Legumbre",en="Bean",color=Color3.fromRGB(198,138,91),shape="grain"},
 bread={name="Pan",en="Bread",color=Color3.fromRGB(237,174,85),shape="cube"},
}
C.Recipes = {
 {id="dew",name="Cuenco del Rocío",en="Dew Bowl",family="ensalada",parts={{key="tomato",state="cut"},{key="leaf",state="cut"}},score=60},
 {id="dew_crisp",name="Rocío Crujiente",en="Crisp Dew",family="ensalada",parts={{key="leaf",state="cut"},{key="mushroom",state="fried"}},score=80},
 {id="tower",name="Torre del Huerto",en="Garden Tower",family="torre",parts={{key="bread",state="raw"},{key="mushroom",state="cooked"},{key="leaf",state="cut"}},score=100},
 {id="tower_red",name="Torre Coral",en="Coral Tower",family="torre",parts={{key="bread",state="raw"},{key="mushroom",state="cooked"},{key="tomato",state="cut"}},score=100},
 {id="roll",name="Rollito de Marea",en="Tide Roll",family="rollo",parts={{key="grain",state="boiled"},{key="leaf",state="cut"}},score=90},
 {id="roll_red",name="Rollito Coral",en="Coral Roll",family="rollo",parts={{key="grain",state="boiled"},{key="tomato",state="cut"}},score=90},
 {id="ribbon",name="Cintas del Molino",en="Mill Ribbons",family="pasta",parts={{key="dough",state="boiled"},{key="tomato",state="cooked"}},score=110},
 {id="ribbon_wood",name="Cintas del Bosque",en="Woodland Ribbons",family="pasta",parts={{key="dough",state="boiled"},{key="mushroom",state="cooked"}},score=110},
 {id="disc",name="Disco del Jardín",en="Garden Disc",family="horno",parts={{key="dough",state="baked"},{key="tomato",state="cut"}},score=110},
 {id="disc_wood",name="Disco Tostado",en="Toasted Disc",family="horno",parts={{key="dough",state="baked"},{key="mushroom",state="cooked"}},score=120},
 {id="wrap",name="Pañuelo del Camino",en="Trail Wrap",family="torta",parts={{key="bread",state="raw"},{key="bean",state="boiled"}},score=90},
 {id="wrap_green",name="Pañuelo Verde",en="Green Wrap",family="torta",parts={{key="bread",state="raw"},{key="leaf",state="cut"},{key="bean",state="boiled"}},score=110},
 {id="cloud",name="Nube de Baya",en="Berry Cloud",family="dulce",parts={{key="dough",state="baked"},{key="berry",state="cut"}},score=120},
 {id="cloud_cocoa",name="Nube de Cacao",en="Cocoa Cloud",family="dulce",parts={{key="dough",state="baked"},{key="cocoa",state="mixed"}},score=120},
 {id="lantern",name="Farolito de Seta",en="Mushroom Lantern",family="vapor",parts={{key="dough",state="steamed"},{key="mushroom",state="cut"}},score=110},
 {id="lantern_green",name="Farolito del Huerto",en="Garden Lantern",family="vapor",parts={{key="dough",state="steamed"},{key="leaf",state="cut"}},score=110},
}
C.Stations = {
 counter={name="Encimera",color=Color3.fromRGB(219,190,148)},
 dispenser={name="Despensa",color=Color3.fromRGB(99,152,136)},
 cut={name="Cortar",color=Color3.fromRGB(215,155,91)},
 stove={name="Plancha",color=Color3.fromRGB(69,91,99),process="cooked"},
 boil={name="Hervir",color=Color3.fromRGB(77,130,151),process="boiled"},
 fryer={name="Freír",color=Color3.fromRGB(226,174,66),process="fried"},
 oven={name="Hornear",color=Color3.fromRGB(177,106,76),process="baked"},
 steam={name="Vapor",color=Color3.fromRGB(96,167,161),process="steamed"},
 mixer={name="Mezclar",color=Color3.fromRGB(181,134,167),process="mixed"},
 trash={name="Papelera",color=Color3.fromRGB(86,103,105)},
 delivery={name="Entregar",color=Color3.fromRGB(231,112,85)},
 sink={name="Lavar",color=Color3.fromRGB(102,170,195)},
 rack={name="Platos",color=Color3.fromRGB(222,222,203)},
 extinguisher={name="Extintor",color=Color3.fromRGB(220,84,67)},
}
C.Levels = {
 {id="vaho_01",name="Mercado de las Cometas",en="Kite Market",dynamic="conveyor",stars={120,260,420,650},unlock=0,recipes={"dew","tower","roll"},accent=Color3.fromRGB(231,124,91)},
 {id="vaho_02",name="Pasarela del Estuario",en="Estuary Crossing",dynamic="platform",stars={130,280,460,700},unlock=1,recipes={"roll","roll_red","wrap"},accent=Color3.fromRGB(86,169,179)},
 {id="vaho_03",name="Invernadero de Cristal",en="Crystal Greenhouse",dynamic="portal",stars={150,300,480,730},unlock=2,recipes={"dew","dew_crisp","ribbon"},accent=Color3.fromRGB(119,177,143)},
 {id="vaho_04",name="Expreso de las Brasas",en="Ember Express",dynamic="wind",stars={140,300,500,760},unlock=3,recipes={"ribbon_wood","wrap_green","disc"},accent=Color3.fromRGB(218,159,78)},
 {id="vaho_05",name="Huerto de los Farolillos",en="Lantern Orchard",dynamic="thief",stars={150,320,520,790},unlock=4,recipes={"lantern","lantern_green","cloud"},accent=Color3.fromRGB(176,134,185)},
 {id="vaho_06",name="Observatorio del Monzón",en="Monsoon Observatory",dynamic="shift",stars={160,340,540,820},unlock=5,recipes={"cloud_cocoa","disc_wood","tower_red"},accent=Color3.fromRGB(110,144,194)},
 {id="vaho_secret_01",name="Taller bajo la Campana",en="Bell Workshop",dynamic="conveyor",stars={200,400,650,950},unlock=9,recipes={"cloud","lantern","dew_crisp"},accent=Color3.fromRGB(209,180,97)},
}
C.Chefs = {"Mara Cobre","Nilo Junco","Uma Tiza","Berto Botón","Lía Remache","Oto Mimbre","Sira Nácar","Teo Cometa","Ada Azafrán","Rumi Musgo","Vera Farol","Polo Nube"}
C.Palette={Color3.fromRGB(230,116,87),Color3.fromRGB(61,139,146),Color3.fromRGB(218,180,93),Color3.fromRGB(137,119,172),Color3.fromRGB(111,161,109),Color3.fromRGB(210,149,174)}
C.Cosmetics = {}
local groups = {{"hat","Cometa","Embudo","Farol","Vela","Maceta"},{"apron","Azulejo","Marea","Trama","Cobre","Jardín"},{"palette","Coral","Petróleo","Crema","Lila","Lima"},{"trail","Chispitas","Burbujas","Hojitas","Cintas","Luciérnagas"}}
for _,group in groups do
 for i=2,#group do table.insert(C.Cosmetics,{id=group[1].."_"..tostring(i-1),name=group[i],slot=group[1],rarity=({"Común","Rara","Épica","Legendaria"})[(i-2)%4+1],price=80+(i-2)*50,color=C.Palette[i-1]}) end
end
C.Emotes={"Saludo de cuchara","Palmas al equipo","Giro del delantal","Respiro del chef","Malabar de cucharas","Reverencia del horno","Baile del batidor","Sombrero saltarín","Aplauso de tapas","Celebración del vapor"}
C.Utensils={"Cobre grabado","Cerámica azul","Madera pintada","Cristal mate"}
function C.recipe(id: string): any
 for _,r in C.Recipes do if r.id==id then return r end end
 return nil
end
return C
