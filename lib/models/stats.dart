class Stats {
  int str;
  int dex;
  int con;
  int intl;
  int wis;
  int cha;

  Stats({
    this.str = 10,
    this.dex = 10,
    this.con = 10,
    this.intl = 10,
    this.wis = 10,
    this.cha = 10,
  });

  Map<String, dynamic> toJson() => {
        'str': str,
        'dex': dex,
        'con': con,
        'int': intl,
        'wis': wis,
        'cha': cha,
      };

  factory Stats.fromJson(Map<String, dynamic> j) => Stats(
        str: (j['str'] ?? 10) as int,
        dex: (j['dex'] ?? 10) as int,
        con: (j['con'] ?? 10) as int,
        intl: (j['int'] ?? 10) as int,
        wis: (j['wis'] ?? 10) as int,
        cha: (j['cha'] ?? 10) as int,
      );
}
