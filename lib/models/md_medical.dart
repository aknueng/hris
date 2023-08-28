class MedicalInfo {
  final String oPDAllow;
  final String oPDUseFamily;
  final String oPDAllowFamily;
  final String oPDUseParent;
  final String oPDAllowParent;
  final String oPDUsePregnant;
  final String oPDAllowPregnant;
  final String oPDRemainPregnant;
  final String oPDUseTotal;
  final String oPDAllowRemain;
  final String iPDAllow;
  final String iPDUse;
  final String iPDAllowRemain;
  final String medicalAllow;
  final String medicalUse;
  final String medicalRemain;

  MedicalInfo({
    required this.oPDAllow,
    required this.oPDUseFamily,
    required this.oPDAllowFamily,
    required this.oPDUseParent,
    required this.oPDAllowParent,
    required this.oPDUsePregnant,
    required this.oPDAllowPregnant,
    required this.oPDRemainPregnant,
    required this.oPDUseTotal,
    required this.oPDAllowRemain,
    required this.iPDAllow,
    required this.iPDUse,
    required this.iPDAllowRemain,
    required this.medicalAllow,
    required this.medicalUse,
    required this.medicalRemain,
  });

  factory MedicalInfo.fromJson(Map<String, dynamic> json) {
    return MedicalInfo(
        oPDAllow: json['opdAllow'],
        oPDUseFamily: json['opdUseFamily'],
        oPDAllowFamily: json['opdAllowFamily'],
        oPDUseParent: json['opdUseParent'],
        oPDAllowParent: json['opdAllowParent'],
        oPDUsePregnant: json['opdUsePregnant'],
        oPDAllowPregnant: json['opdAllowPregnant'],
        oPDRemainPregnant: json['opdRemainPregnant'],
        oPDUseTotal: json['opdUseTotal'],
        oPDAllowRemain: json['opdAllowRemain'],
        iPDAllow: json['ipdAllow'],
        iPDUse: json['ipdUse'],
        iPDAllowRemain: json['ipdAllowRemain'],
        medicalAllow: json['medicalAllow'],
        medicalUse: json['medicalUse'],
        medicalRemain: json['medicalRemain']);
  }
}
