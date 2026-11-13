import 'package:dio/dio.dart';
import 'package:ezsports/features/auth/data/auth_repository.dart';
import 'package:ezsports/core/storage/app_store.dart';
import 'package:ezsports/core/constants/app_colors.dart';
import 'package:ezsports/core/constants/app_text_styles.dart';
import 'package:ezsports/core/widgets/app_button.dart';
import 'package:ezsports/features/fees/data/fees_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountantHomeScreen extends StatefulWidget {
  const AccountantHomeScreen({super.key});

  @override
  State<AccountantHomeScreen> createState() => _AccountantHomeScreenState();
}

class _AccountantHomeScreenState extends State<AccountantHomeScreen> {
  final FeesRepository _fees = FeesRepository();
  final TextEditingController _searchController = TextEditingController();
  String _kind = AppStore.feeKind;
  bool _loading = true;
  String _error = '';
  List<FeeAccount> _players = <FeeAccount>[];
  List<FeeAccount> _coaches = <FeeAccount>[];
  List<FeeBill> _bills = <FeeBill>[];

  @override
  void initState() {
    super.initState();
    _players = _fees.storedPlayers();
    _coaches = _fees.storedCoaches();
    _bills = _fees.storedBills();
    _loading = _players.isEmpty && _coaches.isEmpty && _bills.isEmpty;
    _searchController.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final bool blank = _players.isEmpty && _coaches.isEmpty && _bills.isEmpty;
    if (blank) {
      setState(() {
        _loading = true;
        _error = '';
      });
    }
    try {
      final List<Object> results = await Future.wait(<Future<Object>>[
        _fees.players(),
        _fees.coaches(),
        _fees.bills(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _players = results[0] as List<FeeAccount>;
        _coaches = results[1] as List<FeeAccount>;
        _bills = results[2] as List<FeeBill>;
        _loading = false;
        _error = '';
      });
    } on DioException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        if (_players.isEmpty && _coaches.isEmpty) {
          _error = _detail(error) ?? 'Fees could not be loaded.';
        }
      });
    }
  }

  List<FeeBill> _billsFor(FeeAccount account) {
    return _bills.where((FeeBill bill) {
      return account.kind == 'player' ? bill.studentId == account.id : bill.coachId == account.id;
    }).toList();
  }

  List<FeeAccount> get _visible {
    final List<FeeAccount> source = _kind == 'player' ? _players : _coaches;
    final String needle = _searchController.text.trim().toLowerCase();
    final List<FeeAccount> rows = source.where((FeeAccount account) {
      if (needle.isEmpty) {
        return true;
      }
      return '${account.name} ${account.contact} ${account.email}'.toLowerCase().contains(needle);
    }).toList()
      ..sort((FeeAccount a, FeeAccount b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return rows;
  }

  Future<void> _open(FeeAccount account) async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => FeeEditorScreen(
          account: account,
          bills: _billsFor(account),
        ),
      ),
    );
    if (saved == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<FeeAccount> accounts = _visible;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: <Widget>[
                  const Expanded(child: Text('Fees', style: AppTextStyles.pageTitle)),
                  TextButton(
                    onPressed: () async {
                      await AuthRepository().logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    child: const Text('Logout', style: AppTextStyles.link),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text('Player and coach accounts', style: AppTextStyles.muted),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: <Widget>[
                  _KindChip(
                    label: 'Players',
                    active: _kind == 'player',
                    onTap: () {
                      setState(() => _kind = 'player');
                      AppStore.saveFeeKind('player');
                    },
                  ),
                  const SizedBox(width: 8),
                  _KindChip(
                    label: 'Coaches',
                    active: _kind == 'coach',
                    onTap: () {
                      setState(() => _kind = 'coach');
                      AppStore.saveFeeKind('coach');
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextField(
                controller: _searchController,
                style: AppTextStyles.bodyOnDark,
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  hintText: 'Search name, mobile, or email',
                  hintStyle: AppTextStyles.muted,
                  filled: true,
                  fillColor: AppColors.searchField,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _error.isNotEmpty && _players.isEmpty && _coaches.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(_error, style: AppTextStyles.bodyOnDark, textAlign: TextAlign.center),
                          ),
                        )
                      : accounts.isEmpty
                          ? Center(
                              child: Text(
                                _searchController.text.trim().isEmpty ? 'No accounts yet.' : 'No one matches that search.',
                                style: AppTextStyles.muted,
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                              itemCount: accounts.length,
                              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
                              itemBuilder: (BuildContext context, int index) {
                                final FeeAccount account = accounts[index];
                                final FeeBill? latest = _billsFor(account).isEmpty ? null : _billsFor(account).first;
                                return Material(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(18),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () => _open(account),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: <Widget>[
                                          CircleAvatar(
                                            backgroundColor: account.kind == 'player' ? AppColors.playerAccent : AppColors.primary,
                                            child: Text(account.initials, style: AppTextStyles.button),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(account.name, style: AppTextStyles.title),
                                                const SizedBox(height: 2),
                                                Text(
                                                  account.contact.isEmpty ? 'No mobile' : account.contact,
                                                  style: AppTextStyles.caption,
                                                ),
                                                Text(
                                                  latest == null
                                                      ? 'No fee yet'
                                                      : '${_rupees(latest.amount)} · ${latest.status}',
                                                  style: AppTextStyles.body,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeeEditorScreen extends StatefulWidget {
  const FeeEditorScreen({super.key, required this.account, required this.bills});

  final FeeAccount account;
  final List<FeeBill> bills;

  @override
  State<FeeEditorScreen> createState() => _FeeEditorScreenState();
}

class _FeeEditorScreenState extends State<FeeEditorScreen> {
  final FeesRepository _fees = FeesRepository();
  late final TextEditingController _amountController;
  late List<FeeBill> _bills;
  int? _billId;
  DateTime? _dueDate;
  String _status = 'due';
  bool _saving = false;
  bool _changed = false;
  String _notice = '';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _bills = List<FeeBill>.from(widget.bills);
    final FeeBill? current = _bills.isEmpty ? null : _bills.first;
    _billId = current?.billId;
    _amountController = TextEditingController(text: current?.amount ?? '');
    _dueDate = current == null ? null : DateTime.tryParse(current.dueDate);
    _status = current?.status ?? 'due';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _choose(FeeBill? bill) {
    setState(() {
      _billId = bill?.billId;
      _amountController.text = bill?.amount ?? '';
      _dueDate = bill == null ? null : DateTime.tryParse(bill.dueDate);
      _status = bill?.status ?? 'due';
      _notice = '';
      _error = '';
    });
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _notice = '';
        _error = '';
      });
    }
  }

  Future<void> _save() async {
    final String amount = _amountController.text.trim();
    final num? parsed = num.tryParse(amount);
    if (parsed == null || parsed <= 0) {
      setState(() {
        _error = 'Enter a fee amount greater than zero.';
        _notice = '';
      });
      return;
    }
    if (_dueDate == null) {
      setState(() {
        _error = 'Choose a due date.';
        _notice = '';
      });
      return;
    }
    setState(() {
      _saving = true;
      _error = '';
      _notice = '';
    });
    final String due = '${_dueDate!.year.toString().padLeft(4, '0')}-'
        '${_dueDate!.month.toString().padLeft(2, '0')}-'
        '${_dueDate!.day.toString().padLeft(2, '0')}';
    try {
      final FeeBill saved = await _fees.save(
        account: widget.account,
        billId: _billId,
        amount: amount,
        dueDate: due,
        status: _status,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _bills = <FeeBill>[saved, ..._bills.where((FeeBill bill) => bill.billId != saved.billId)];
        _billId = saved.billId;
        _notice = 'Saved';
        _changed = true;
        _saving = false;
      });
    } on DioException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _error = _detail(error) ?? 'The fee could not be saved.';
      });
    } on FormatException {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _error = 'Enter a fee amount greater than zero.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final FeeAccount account = widget.account;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          Navigator.of(context).pop(_changed);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(_changed),
                  child: const Text('Back', style: AppTextStyles.link),
                ),
              ),
              Text(account.name, style: AppTextStyles.pageTitle),
              const SizedBox(height: 4),
              Text(
                account.kind == 'player' ? 'Player account' : 'Coach account',
                style: AppTextStyles.muted,
              ),
              if (account.email.isNotEmpty) Text(account.email, style: AppTextStyles.muted),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _KindChip(label: 'New fee', active: _billId == null, onTap: () => _choose(null)),
                  ..._bills.map(
                    (FeeBill bill) => _KindChip(
                      label: '${_rupees(bill.amount)} · ${_formatDate(bill.dueDate)}',
                      active: bill.billId == _billId,
                      onTap: () => _choose(bill),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_billId == null ? 'Add fee' : 'Update fee', style: AppTextStyles.title),
                    const SizedBox(height: 12),
                    const Text('Amount', style: AppTextStyles.caption),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: AppTextStyles.body,
                      decoration: _fieldDecoration(),
                      onChanged: (_) => setState(() {
                        _notice = '';
                        _error = '';
                      }),
                    ),
                    const SizedBox(height: 12),
                    const Text('Due date', style: AppTextStyles.caption),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: _fieldDecoration(),
                        child: Text(
                          _dueDate == null ? 'Choose a date' : _formatDate(_iso(_dueDate!)),
                          style: AppTextStyles.body,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Status', style: AppTextStyles.caption),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      style: AppTextStyles.body,
                      dropdownColor: AppColors.card,
                      decoration: _fieldDecoration(),
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(value: 'due', child: Text('due')),
                        DropdownMenuItem<String>(value: 'paid', child: Text('paid')),
                        DropdownMenuItem<String>(value: 'overdue', child: Text('overdue')),
                      ],
                      onChanged: (String? value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _status = value;
                          _notice = '';
                          _error = '';
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: _saving ? 'Saving' : 'Save',
                onPressed: () {
                  if (!_saving) {
                    _save();
                  }
                },
              ),
              if (_notice.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Text(_notice, style: AppTextStyles.bodyOnDark.copyWith(color: AppColors.success)),
              ],
              if (_error.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Text(_error, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.primary : AppColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: active ? AppColors.onPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: AppColors.cardBeige,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );
}

String? _detail(DioException error) {
  final Object? data = error.response?.data;
  if (data is Map<String, dynamic>) {
    return data['detail']?.toString();
  }
  return null;
}

String _rupees(String raw) {
  final double? value = double.tryParse(raw);
  if (value == null) {
    return raw;
  }
  if (value == value.roundToDouble()) {
    return '₹${value.toInt()}';
  }
  return '₹${value.toStringAsFixed(2)}';
}

String _iso(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String _formatDate(String iso) {
  final DateTime? date = DateTime.tryParse(iso);
  if (date == null) {
    return iso;
  }
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
