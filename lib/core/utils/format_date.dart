import 'package:intl/intl.dart';

String formatDateBydMMMYYYY(DateTime dateTime) {
  return DateFormat("d MMM, yyyy").format(dateTime);
}

String formatDateDDMMYYYYHHMM(DateTime dateTime) {
  return DateFormat("dd-MM-yyyy HH:mm").format(dateTime);
}
