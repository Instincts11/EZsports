import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/features/bills/presentation/screens/create_bill_screen.dart';
import 'package:ezsports/features/bills/presentation/widgets/bill_status_chip.dart';
import 'package:flutter/material.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bills')),
      body: ListView(
        children: const <Widget>[
          ListTile(
            title: Text('Arjun Menon', style: AppTextStyles.body),
            subtitle: Text('Due 20 Sep 2026'),
            trailing: BillStatusChip(status: 'due'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CreateBillScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
