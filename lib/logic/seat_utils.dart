const berthTypes = [
  'Lower',
  'Middle',
  'Upper',
  'Lower',
  'Middle',
  'Upper',
  'Side Lower',
  'Side Upper'
];

int bayOf(int seat) => (seat - 1) ~/ 8;
String berthOf(int seat) => berthTypes[(seat - 1) % 8];
int coachNo(String coach) => int.parse(coach.substring(1)); // 'S2' -> 2
String seatLabel(String coach, int seat) => '$coach / $seat'; // 'S2 / 43'
String seatKey(String coach, int seat) => '$coach/$seat'; // 'S2/43' (DB snapshot)
int bayStartSeat(int seat) => bayOf(seat) * 8 + 1;
int bayEndSeat(int seat) => bayOf(seat) * 8 + 8;
