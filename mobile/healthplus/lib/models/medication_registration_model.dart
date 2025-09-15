/// 약 형태 열거형
enum MedicationForm {
  tablet('정', '알약'),
  capsule('캡슐', '캡슐'),
  syrup('시럽', '액체'),
  other('기타', '기타');

  const MedicationForm(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// 식사 관계 열거형
enum MealRelation {
  beforeMeal('식전', '식사 전'),
  afterMeal('식후', '식사 후'),
  irrelevant('상관없음', '식사와 상관없음');

  const MealRelation(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// 복용량 단위 열거형
enum DosageUnit {
  tablet('정', '알약'),
  capsule('캡슐', '캡슐'),
  ml('ml', '밀리리터'),
  mg('mg', '밀리그램'),
  other('기타', '기타');

  const DosageUnit(this.displayName, this.description);
  final String displayName;
  final String description;
}

/// 약 등록 정보 모델
class MedicationRegistration {
  final String id;
  final String name;
  final String? imagePath;
  final int dailyDosageCount;
  final List<String> dosageTimes;
  final MedicationForm form;
  final int singleDosageAmount;
  final DosageUnit dosageUnit;
  final bool hasMealRelation;
  final MealRelation? mealRelation;
  final bool isContinuous;
  final String? memo;

  const MedicationRegistration({
    required this.id,
    required this.name,
    this.imagePath,
    required this.dailyDosageCount,
    required this.dosageTimes,
    required this.form,
    required this.singleDosageAmount,
    required this.dosageUnit,
    required this.hasMealRelation,
    this.mealRelation,
    required this.isContinuous,
    this.memo,
  });

  MedicationRegistration copyWith({
    String? id,
    String? name,
    String? imagePath,
    int? dailyDosageCount,
    List<String>? dosageTimes,
    MedicationForm? form,
    int? singleDosageAmount,
    DosageUnit? dosageUnit,
    bool? hasMealRelation,
    MealRelation? mealRelation,
    bool? isContinuous,
    String? memo,
  }) {
    return MedicationRegistration(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      dailyDosageCount: dailyDosageCount ?? this.dailyDosageCount,
      dosageTimes: dosageTimes ?? this.dosageTimes,
      form: form ?? this.form,
      singleDosageAmount: singleDosageAmount ?? this.singleDosageAmount,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      hasMealRelation: hasMealRelation ?? this.hasMealRelation,
      mealRelation: mealRelation ?? this.mealRelation,
      isContinuous: isContinuous ?? this.isContinuous,
      memo: memo ?? this.memo,
    );
  }
}

/// 약 등록 화면 기본값
class MedicationRegistrationDefaults {
  static const MedicationRegistration initial = MedicationRegistration(
    id: '',
    name: '',
    dailyDosageCount: 2,
    dosageTimes: ['08:00'],
    form: MedicationForm.tablet,
    singleDosageAmount: 1,
    dosageUnit: DosageUnit.tablet,
    hasMealRelation: true,
    mealRelation: MealRelation.afterMeal,
    isContinuous: true,
  );
}
