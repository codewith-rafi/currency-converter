import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// A currency converter widget that allows conversion
/// between USD and RMB using real-time exchange rates.
class CurrencyDesign extends StatefulWidget {
  const CurrencyDesign({super.key});

  @override
  State<CurrencyDesign> createState() => _CurrencyDesignState();
}

class _CurrencyDesignState extends State<CurrencyDesign> {
  double result = 0;          // Stores the converted result
  double exchageRate = 0;     // Current exchange rate (USD -> RMB)

  bool isLoading = true;      // Whether the exchange rate is being fetched
  bool usdToRmb = true;       // Conversion direction (true = USD → RMB)

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch exchange rate once the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchExchangeRate();
    });
  }

  /// Fetches the latest exchange rate from the API.
  /// If successful, updates the [exchageRate].
  /// If failed, sets exchange rate to 0.
  Future<void> fetchExchangeRate() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('your api key'); // Replace with actual API endpoint
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check for failure response from API
        if (data['success'] == false) {
          setState(() {
            exchageRate = 0;
            isLoading = false;
          });
          return;
        }

        // Update state with fetched exchange rate
        setState(() {
          exchageRate = data['quotes']['USDCNY'];
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle API errors or connectivity issues
      setState(() {
        exchageRate = 0;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Common border style for input fields
    final border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white24, width: 1.5),
      borderRadius: BorderRadius.circular(15),
    );

    // Change label & output currency dynamically based on conversion mode
    final inputLabel = usdToRmb ? 'Enter amount in USD' : 'Enter amount in RMB';
    final outputCurrency = usdToRmb ? 'RMB' : 'USD';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1E1E2C),
              const Color(0xFF27293D).withValues(alpha: 0.90),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            /// App title
            const Text(
              "Currency Converter",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 30),

            /// Toggle switch: USD ↔ RMB
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "USD - RMB",
                  style: TextStyle(
                    color: usdToRmb ? Colors.white : Colors.white54,
                    fontWeight: usdToRmb ? FontWeight.bold : FontWeight.normal,
                  ),
                ),

                Switch(
                  activeColor: Colors.tealAccent,
                  value: usdToRmb,
                  onChanged: (value) {
                    setState(() {
                      usdToRmb = value;
                      result = 0;                     // Reset result
                      textEditingController.clear();  // Clear input field
                    });
                  },
                ),

                Text(
                  "RMB - USD",
                  style: TextStyle(
                    color: !usdToRmb ? Colors.white : Colors.white54,
                    fontWeight: !usdToRmb ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// Result display box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isLoading
                      ? "Loading rate..."
                      : "${result.toStringAsFixed(2)} $outputCurrency",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// Input field for amount
            SizedBox(
              width: double.infinity,
              height: 55,
              child: TextField(
                controller: textEditingController,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: inputLabel,
                  hintStyle: const TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: Colors.white12,
                  enabledBorder: border,
                  focusedBorder: border.copyWith(
                    borderSide: const BorderSide(
                        color: Colors.tealAccent, width: 2),
                  ),
                  prefixIcon: usdToRmb
                      ? const Icon(Icons.attach_money,
                          color: Colors.tealAccent)
                      : const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            '¥',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.tealAccent,
                            ),
                          ),
                        ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),

            const SizedBox(height: 25),

            /// Convert button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (exchageRate == 0 || isLoading)
                    ? null // Disabled if rate unavailable
                    : () {
                        setState(() {
                          final input =
                              double.tryParse(textEditingController.text) ?? 0;

                          if (usdToRmb) {
                            result = input * exchageRate;
                          } else {
                            result = input / exchageRate;
                          }
                        });
                      },
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Colors.grey.shade800;
                    }
                    return Colors.tealAccent;
                  }),
                  foregroundColor: WidgetStateProperty.all(Colors.black),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  elevation: WidgetStateProperty.all(8),
                ),
                child: const Text(
                  "Convert",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Display current exchange rate
            Text(
              isLoading
                  ? "Fetching latest exchange rate..."
                  : "Exchange Rate : 1 USD = ${exchageRate.toStringAsFixed(2)} RMB",
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            )
          ],
        ),
      ),
    );
  }
}
