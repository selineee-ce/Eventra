import 'lib/core/utils/search_match.dart';

void main() {
  String featuredTitle = "Sabrina Carpenter: Short n Sweet Tour";
  String eventTitle = "Sabrina Carpenter: Short n Sweet Tour";
  String artistName = "Sabrina Carpenter";
  
  final score1 = searchMatchScore(featuredTitle, [
    eventTitle,
    artistName,
  ]);
  
  print("score1 = $score1");
}
