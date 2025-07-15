class ConverterNumberArabicRomain {
  static String GetLettersRomanFromArabicNumber(String input) {
    if (int.tryParse(input) == null) {
      return 'Error';
    }

    int value = int.parse(input);

    List<int> iNum = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    List<String> rNum = [
      'M',
      'CM',
      'D',
      'CD',
      'C',
      'XC',
      'L',
      'XL',
      'X',
      'IX',
      'V',
      'IV',
      'I'
    ];

    var nRoman = '';

    for (var i = 0; i < iNum.length; i++) {
      while (iNum[i] <= value) {
        nRoman += rNum[i];
        value -= iNum[i];
      }
    }

    return nRoman;
  }

  static int GetNumberArabicFromRomanLetters(String romanLetters) {
    var romanSymbols = {
      'I': 1,
      'V': 5,
      'X': 10,
      'L': 50,
      'C': 100,
      'D': 500,
      'M': 1000,
    };

    int result = 0;

    int lastValue = 0;
    bool error = false;

    for (int i = romanLetters.length - 1; i >= 0; i--) {
      if ('IVXLCDM'.contains(romanLetters[i]) && !error) {
        int currentValue = romanSymbols[romanLetters[i]]!;

        if (currentValue >= lastValue) {
          result += currentValue;
        } else {
          result -= currentValue;
        }

        lastValue = currentValue;
      } else {
        error = true;
      }
    }

    if (error) {
      return 0;
    } else {
      return result;
    }
  }
}
