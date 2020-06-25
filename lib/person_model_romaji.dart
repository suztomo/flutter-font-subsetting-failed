
Map<String, String> hebonMapping = <String, String>{
  'あ':'a',
  'い':'i',
  'う':'u',
  'え':'e',
  'お':'o',
  'か':'ka',
  'き':'ki',
  'く':'ku',
  'け':'ke',
  'こ':'ko',
  'きゃ':'kya',
  'きゅ':'kyu',
  'きょ':'kyo',
  'が':'ga',
  'ぎ':'gi',
  'ぐ':'gu',
  'げ':'ge',
  'ご':'go',
  'ぎゃ':'gya',
  'ぎゅ':'gyu',
  'ぎょ':'gyo',
  'さ':'sa',
  'し':'shi',
  'す':'su',
  'せ':'se',
  'そ':'so',
  'しゃ':'sha',
  'しゅ':'shu',
  'しょ':'sho',
  'ざ':'za',
  'じ':'ji',
  'ず':'zu',
  'ぜ':'ze',
  'ぞ':'zo',
  'じゃ':'ja',
  'じゅ':'ju',
  'じょ':'jo',
  'た':'ta',
  'ち':'chi',
  'つ':'tsu',
  'て':'te',
  'と':'to',
  'ちゃ':'cha',
  'ちゅ':'chu',
  'ちょ':'cho',
  'だ':'da',
  'で':'de',
  'ど':'do',
  'な':'na',
  'に':'ni',
  'ぬ':'nu',
  'ね':'ne',
  'の':'no',
  'にゃ':'nya',
  'にゅ':'nyu',
  'にょ':'nyo',
  'は':'ha',
  'ひ':'hi',
  'ふ':'fu',
  'へ':'he',
  'ほ':'ho',
  'ひゃ':'hya',
  'ひゅ':'hyu',
  'ひょ':'hyo',
  'ば':'ba',
  'び':'bi',
  'ぶ':'bu',
  'べ':'be',
  'ぼ':'bo',
  'びゃ':'bya',
  'びゅ':'byu',
  'びょ':'byo',
  'ぱ':'pa',
  'ぴ':'pi',
  'ぷ':'pu',
  'ぺ':'pe',
  'ぽ':'po',
  'ぴゃ':'pya',
  'ぴゅ':'pyu',
  'ぴょ':'pyo',
  'ま':'ma',
  'み':'mi',
  'む':'mu',
  'め':'me',
  'も':'mo',
  'みゃ':'mya',
  'みゅ':'myu',
  'みょ':'myo',
  'や':'ya',
  'ゆ':'yu',
  'よ':'yo',
  'ら':'ra',
  'り':'ri',
  'る':'ru',
  'れ':'re',
  'ろ':'ro',
  'りゃ':'rya',
  'りゅ':'ryu',
  'りょ':'ryo',
  'わ':'wa',
};

String toRomaji(String text, Map<String, String> mapping) {
  var ret = '';
  for (var i=0; i<text.length; ++i) {
    final t = text[i];
    if (mapping.containsKey(t)) {
      ret += mapping[t];
    } else {
      ret += t;
    }
  }
  return ret;
}

bool matchRomaji(String name, String query) {
  if (query.length < 2 || name == null) {
    return false;
  }
  final nameRomaji = toRomaji(name, hebonMapping).toLowerCase();
  final queryRomaji = toRomaji(query, hebonMapping).toLowerCase();
  final ret = nameRomaji.contains(queryRomaji);
  return ret;
}
