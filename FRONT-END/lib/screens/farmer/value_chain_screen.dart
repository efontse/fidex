import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../services/value_chain_service.dart';

class ValueChainScreen extends StatefulWidget {
  final ProductModel? preselectedProduct;

  const ValueChainScreen({super.key, this.preselectedProduct});

  @override
  State<ValueChainScreen> createState() => _ValueChainScreenState();
}

class _ValueChainScreenState extends State<ValueChainScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedProductId;
  String _selectedStatus = 'Harvested';
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _statuses = [
    'Harvested',
    'Washed & Graded',
    'Quality Tested & Certified',
    'Cold Storage Depot',
    'Packaged & Boxed',
    'Ready for Fleet Dispatch',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.preselectedProduct != null) {
      _selectedProductId = widget.preselectedProduct!.id;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      final response = await ValueChainService.addEvent(
        productId: _selectedProductId,
        status: _selectedStatus,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Value chain milestone recorded successfully!'),
            backgroundColor: AppColors.statusSuccess,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.statusError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final farmerProducts = productProvider.farmerProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Record Value Chain Milestone'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Associate Agricultural Good (Optional)',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int?>(
                      value: _selectedProductId,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('General Farm Level Milestone'),
                        ),
                        ...farmerProducts.map(
                          (p) => DropdownMenuItem<int?>(
                            value: p.id,
                            child: Text('${p.name} (${p.category})'),
                          ),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedProductId = val),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Production & Processing Stage',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      items: _statuses
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Field Notes & Quality Observations',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Moisture content tested at 7.2%. Stored at Plot B warehouse in ventilated crates.',
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Save Traceability Record'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
