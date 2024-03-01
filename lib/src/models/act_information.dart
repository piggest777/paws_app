import 'package:paws_app/src/models/act_item.dart';

class ActInformation {
  // String actDate;
  String reciverFondName;
  String reciverFondNumber;
  // String declarationCode;
  // String declarationDate;
  // String humanitarianAidCode;
  String recipientOrganizationName;
  String recipientName;
  String recipientNumber;
  String postNumber;
  String address;
  String phoneNumber;
  List<ActItem> items;

  ActInformation({
    // this.actDate = '',
    this.reciverFondName = 'ГО «Захисту прав тварин «ДОБЕРМАН»',
    this.reciverFondNumber = '44833113',
    // this.declarationCode = '',
    // this.declarationDate = '',
    // this.humanitarianAidCode = '',
    this.recipientOrganizationName = '',
    this.recipientName = '',
    this.recipientNumber = '',
    this.postNumber = '',
    this.address = '',
    this.phoneNumber = '',
    List<ActItem>? items,
  }) : items = items ?? [];
}

