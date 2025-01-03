String msToTime(int ms) {
  int s = (ms / 1000).floor();
  return "${(s / 60).floor().toString()}:${(s % 60).toString().padLeft(2, "0")}";
}

String addCommas(String number) {
  if (number.length < 4) return number;
  return number.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}
