import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  _CurrencyPageState createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'INR';
  double _convertedAmount = 0.0;
  bool _isLoading = false;

  List<String> _currencies = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    String apiKey = '1e0005d7e99ebab309f9e8fb';
    String url = 'https://v6.exchangerate-api.com/v6/$apiKey/latest/USD';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          _currencies = data['conversion_rates'].keys.toList();
        });
      }
    } catch (e) {
      print('Error fetching currency list: $e');
    }
  }

  Future<void> _convertCurrency() async {
    if (_amountController.text.isEmpty) return;
    double inputAmount = double.tryParse(_amountController.text) ?? 0.0;
    if (inputAmount <= 0) return;

    setState(() {
      _isLoading = true;
    });

    String apiKey = '1e0005d7e99ebab309f9e8fb';
    String url =
        'https://v6.exchangerate-api.com/v6/$apiKey/latest/$_fromCurrency';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['conversion_rates'] != null &&
            data['conversion_rates'].containsKey(_toCurrency)) {
          double rate = data['conversion_rates'][_toCurrency];
          setState(() {
            _convertedAmount = inputAmount * rate;
          });
        }
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String getFlagUrl(String currencyCode) {
    String countryCode = currencyCode.substring(0, 2);
    return 'https://flagsapi.com/$countryCode/flat/64.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Currency Converter",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  " ${_convertedAmount.toStringAsFixed(3)}",
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Text("Converted Currency",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 30),
                _buildInputField(),
                const SizedBox(height: 20),
                _buildCurrencySelection(),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : _buildConvertButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 18),
        decoration: const InputDecoration(
            labelText: "AMOUNT", border: InputBorder.none),
      ),
    );
  }

  Widget _buildCurrencySelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDropdown(_fromCurrency, (value) {
          setState(() {
            _fromCurrency = value!;
          });
        }),
        const Icon(Icons.swap_horiz, size: 30, color: Colors.white),
        _buildDropdown(_toCurrency, (value) {
          setState(() {
            _toCurrency = value!;
          });
        }),
      ],
    );
  }

  Widget _buildDropdown(String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: Colors.white,
        underline: Container(),
        items: _currencies.map((String currency) {
          return DropdownMenuItem<String>(
            value: currency,
            child: Row(
              children: [
                Image.network(getFlagUrl(currency),
                    width: 30,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.flag)),
                const SizedBox(width: 5),
                Text(currency, style: const TextStyle(fontSize: 16)),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildConvertButton() {
    return ElevatedButton(
      onPressed: _convertCurrency,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text("CONVERT",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
