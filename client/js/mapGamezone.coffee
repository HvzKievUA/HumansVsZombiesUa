$(document).ready ->
	map = new GMaps {
		div: '#map_gamezone'
		lat: 50.44885153
		lng: 30.45546781
		styles:
			[
				{"featureType": "water", "elementType": "all", "stylers": [
					{"visibility": "on"},
					{"color": "#2D333C"},
					{"weight": 0.1}
				]},
				{"featureType": "all", "elementType": "all", "stylers": [
					{"invert_lightness": true},
					{"hue": "#ff0000"},
					{"saturation": -100},
					{"lightness": 30},
					{"gamma": 0.4}
				]},
				{"featureType": "water", "elementType": "geometry", "stylers": [
					{"color": "#2D333C"}
				]},
				{"featureType": "water", "elementType": "labels.text", "stylers": [
					{"visibility": "off"}
				]},
				{"featureType": "road", "elementType": "geometry.fill", "stylers": [
					{"color": "#75551a"},
					{"weight": 2},
					{"lightness": 0}
				]},
				{"featureType": "road", "elementType": "geometry.stroke", "stylers": [
					{"color": "#382602"},
					{"weight": 1}
				]},
				{"featureType": "poi", "elementType": "all", "stylers": [
					{"visibility": "off"}
				]},
				{"featureType": "poi", "elementType": "labels.text.fill", "stylers": [
					{"visibility": "on"},
					{"color": "#757575"},
					{"weight": 0.1}
				]},
				{"featureType": "poi", "elementType": "labels.text.stroke", "stylers": [
					{"visibility": "on"},
					{"color": "#000000"},
					{"weight": 0.5}
				]},
				{"featureType": "poi", "elementType": "labels.icon", "stylers": [
					{"visibility": "on"}
				]},
				{"featureType": "poi", "elementType": "labels", "stylers": [
					{"visibility": "on"}
				]},
				{"featureType": "road.highway", "elementType": "geometry.fill", "stylers": [
					{"visibility": "on"},
					{"weight": 4.51},
					{"lightness": 4}
				]},
				{"featureType": "poi.school", "elementType": "geometry.fill", "stylers": [
					{"visibility": "on"},
					{"lightness": -10}
				]},
				{"featureType": "poi.business", "elementType": "geometry.fill", "stylers": [
					{"visibility": "on"},
					{"lightness": -20}
				]}
			]
	}

	path = [
		[50.453213927513126, 30.45290000620298]
		[50.451164969062354, 30.465558691648766]
		[50.44997585788083, 30.464355050353333]
		[50.44966621234324, 30.46504028234233]
		[50.449542385674235, 30.465202563452067]
		[50.44951676343453, 30.46526693576527]
		[50.449320446303624, 30.466080381302163]
		[50.44901643472439, 30.466016008285806]
		[50.448931037861946, 30.465896649984643]
		[50.44877433421849, 30.465731694130227]
		[50.44873633243932, 30.46564787509851]
		[50.448698757616405, 30.465519129065797]
		[50.44867057647963, 30.465295835165307]
		[50.44866160975079, 30.465224756626412]
		[50.448650081096915, 30.465138255385682]
		[50.4486398334022, 30.465061141876504]
		[50.44862061896867, 30.4649075854104]
		[50.448607809341965, 30.46480096760206]
		[50.44858005513891, 30.464628635672852]
		[50.44854504212107, 30.464411376742646]
		[50.44850234328373, 30.46422295155935]
		[50.44847885890678, 30.464121698169038]
		[50.44843744097718, 30.464146508602425]
		[50.44835844791822, 30.464191435603425]
		[50.44820686627353, 30.464279277948663]
		[50.44808987053124, 30.464348344830796]
		[50.44799294318259, 30.464406012324616]
		[50.44785545118444, 30.464487149147317]
		[50.447680383155195, 30.464587731985375]
		[50.4474980555191, 30.464692338136956]
		[50.44738532801092, 30.464755370048806]
		[50.447285410222335, 30.46481169643812]
		[50.44716158019158, 30.464881433872506]
		[50.44712485812016, 30.464899538783357]
		[50.447071909967036, 30.464930384187028]
		[50.44697796954952, 30.46498134615831]
		[50.446836631569994, 30.46506047132425]
		[50.44669700118778, 30.465135573176667]
		[50.44656847255128, 30.465209333924577]
		[50.44644079758005, 30.46528175356798]
		[50.44636906032132, 30.46532131615095]
		[50.446306717139066, 30.46535752597265]
		[50.446295187911446, 30.4652944940608]
		[50.446278961586316, 30.465219392208382]
		[50.44623583369513, 30.464996768860146]
		[50.446203808007894, 30.464834495214745]
		[50.446190570717526, 30.464772804407403]
		[50.446169647250976, 30.46466216328554]
		[50.446146161716285, 30.464544146088883]
		[50.44611157390764, 30.46437449636869]
		[50.44608509927158, 30.4642410564702]
		[50.44605606255693, 30.46409487607889]
		[50.44602574479173, 30.463944672374055]
		[50.44599884309649, 30.46380720916204]
		[50.44596297414571, 30.463634877232835]
		[50.44591771090715, 30.463409571675584]
		[50.44588824707764, 30.463269426254556]
		[50.445881841894874, 30.46322181704454]
		[50.445872020612974, 30.463164820102975]
		[50.44584469181781, 30.463004558114335]
		[50.445823768198316, 30.46284898999147]
		[50.44580754171157, 30.462704150704667]
		[50.44579515833631, 30.46253181877546]
		[50.445785337036426, 30.462386979488656]
		[50.445781920931616, 30.462192519335076]
		[50.445778504826606, 30.461961849359795]
		[50.44577508872132, 30.46173587325029]
		[50.445780639892284, 30.461540071992204]
		[50.44578960716706, 30.46132348361425]
		[50.445795585349316, 30.461181997088715]
		[50.44581309287871, 30.46097010257654]
		[50.44583487052818, 30.46070389333181]
		[50.4458630533538, 30.46041756751947]
		[50.44589166317476, 30.460124536184594]
		[50.445926251144144, 30.45976377907209]
		[50.445956141961545, 30.459508298663422]
		[50.44599927010766, 30.459181069163606]
		[50.446049230386194, 30.458778067259118]
		[50.446088088344126, 30.458484365371987]
		[50.44613804852889, 30.45808873954229]
		[50.44618288454723, 30.45774675789289]
		[50.4463021401428, 30.456849317997694]
		[50.44638412568842, 30.456269960850477]
		[50.44652076794882, 30.4551756195724]
		[50.4466437456458, 30.454285126179457]
		[50.44666349463854, 30.453962674364448]
		[50.44667715880167, 30.453742733225226]
		[50.44667715880167, 30.453265300020576]
		[50.44666007859715, 30.452744951471686]
		[50.44659858980982, 30.452256789430976]
		[50.44653026884131, 30.451993932947516]
		[50.4463218892781, 30.45117317698896]
		[50.446065683639446, 30.45018075965345]
		[50.44569332897165, 30.44870018027723]
		[50.44555289456241, 30.448166127316654]
		[50.44525739913467, 30.4469859553501]
		[50.4453615913747, 30.446983273141086]
		[50.445851804245, 30.446994001977146]
		[50.44614558792183, 30.44700204860419]
		[50.44627369069825, 30.447597499005497]
		[50.44644620188923, 30.448217089287937]
		[50.44699959988094, 30.448563094250858]
		[50.44740952014674, 30.448825950734317]
		[50.447629850822324, 30.448906417004764]
		[50.44820373055658, 30.449142451398075]
		[50.4490508736342, 30.44946431647986]
		[50.44988946202489, 30.449810321442783]
		[50.449778821726916, 30.450711837038398]
		[50.44959436728306, 30.452085128054023]
		[50.4494748130928, 30.452964892610908]
		[50.45007714431201, 30.452882645186037]
	]

	polygon = map.drawPolygon {
		paths: path
		strokeColor: '#FF0000'
		strokeOpacity: 0.5
		strokeWeight: 2
		fillColor: '#FF0000'
		fillOpacity: 0.1
	}