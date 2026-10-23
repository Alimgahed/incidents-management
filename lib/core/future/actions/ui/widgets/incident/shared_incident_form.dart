import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/branch/branch_model.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/data/repos/add_incident/add_incdient_repo.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/add_incident_states.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_incident_type_states.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_cubit.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_states.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/widget/fields.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident/add_incident_widget.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';

class SharedIncidentForm extends StatefulWidget {
  final TextEditingController descriptionController;
  final TextEditingController notesController;
  final TextEditingController addressController;
  final bool isWeb;

  const SharedIncidentForm({
    super.key,
    required this.descriptionController,
    required this.notesController,
    required this.addressController,
    this.isWeb = false,
  });

  @override
  State<SharedIncidentForm> createState() => _SharedIncidentFormState();
}

class _SharedIncidentFormState extends State<SharedIncidentForm> {
  int? selectedTypeId;
  int? selectedSeverity;
  int? selectedBranchId;
  String? selectedBranchName;
  List<BranchModel> _branches = [];
  bool _isLoadingBranches = false;

  static const List<BranchModel> _fallbackBranches = [
    BranchModel(branchId: 1, branchName: 'ديوان عام الشركة'),
    BranchModel(branchId: 213, branchName: 'المنيا'),
    BranchModel(branchId: 373, branchName: 'المنيا الجديدة'),
    BranchModel(branchId: 173, branchName: 'سمالوط'),
    BranchModel(branchId: 133, branchName: 'مطاي'),
    BranchModel(branchId: 93, branchName: 'بني مزار'),
    BranchModel(branchId: 53, branchName: 'مغاغة'),
    BranchModel(branchId: 13, branchName: 'العدوة'),
    BranchModel(branchId: 253, branchName: 'أبو قرقاص'),
    BranchModel(branchId: 293, branchName: 'ملوي'),
    BranchModel(branchId: 333, branchName: 'ديرمواس'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchBranchesFromApi();
  }

  Future<void> _fetchBranchesFromApi() async {
    setState(() => _isLoadingBranches = true);
    try {
      final res = await getIt<AddIncdientRepo>().getBranches();
      res.when(
        success: (data) {
          if (mounted) {
            setState(() {
              _branches = data.isNotEmpty ? data : _fallbackBranches;
              _isLoadingBranches = false;
            });
          }
        },
        error: (_) {
          if (mounted) {
            setState(() {
              _branches = _fallbackBranches;
              _isLoadingBranches = false;
            });
          }
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _branches = _fallbackBranches;
          _isLoadingBranches = false;
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      selectedTypeId = null;
      selectedSeverity = null;
      selectedBranchId = null;
      selectedBranchName = null;
    });
    widget.descriptionController.clear();
    widget.notesController.clear();
    widget.addressController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddIncidentCubit, AddIncidentStates>(
      listener: (context, state) {
        state.whenOrNull(
          success: () {
            _resetForm();
          },
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IncidentTypeDropdown(
            selectedValue: selectedTypeId,
            onChanged: (v) {
              setState(() {
                selectedTypeId = v;
            });
          },
        ),
        const SizedBox(height: 16),
        CustomDropdownFormField(
          value: selectedSeverity,
          hintText: 'درجة الخطورة',
          items: const [
            DropdownMenuItem(value: 1, child: Text('منخفض')),
            DropdownMenuItem(value: 2, child: Text('متوسطة')),
            DropdownMenuItem(value: 3, child: Text('مرتفعة')),
            DropdownMenuItem(value: 4, child: Text('حرجة')),
          ],
          onChanged: (v) {
            setState(() {
              selectedSeverity = v;
            });
          },
        ),
        const SizedBox(height: 16),
        CustomDropdownFormField<int>(
          value: selectedBranchId,
          hintText: _isLoadingBranches ? 'جاري تحميل الفروع...' : 'الفرع',
          items: _branches
              .map(
                (branch) => DropdownMenuItem<int>(
                  value: branch.branchId,
                  child: Text(branch.branchName),
                ),
              )
              .toList(),
          onChanged: (v) {
            setState(() {
              selectedBranchId = v;
              final match = _branches.where((b) => b.branchId == v);
              selectedBranchName = match.isNotEmpty ? match.first.branchName : null;
            });
          },
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: widget.descriptionController,
          hintText: "اشرح الحالة بالتفصيل...",
          maxLines: widget.isWeb ? 6 : 4,
        ),
        const SizedBox(height: 16),
        BlocListener<MapCubit, MapState>(
          listenWhen: (previous, current) =>
              previous.address != current.address,
          listener: (context, state) {
            if (state.address != null) {
              widget.addressController.text = state.address!;
            }
          },
          child: CustomTextFormField(
            controller: widget.addressController,
            hintText: "العنوان بالتفصيل",
            useValidator: false,
            maxLines: 2,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextFormField(
          controller: widget.notesController,
          hintText: "ملاحظات إضافية (اختياري)",
          useValidator: false,
          maxLines: widget.isWeb ? 4 : 3,
        ),
        const SizedBox(height: 30),
        BlocBuilder<AddIncidentCubit, AddIncidentStates>(
          builder: (context, state) {
            return CustomButton(
              text: state.maybeWhen(
                loading: () => 'جاري الإرسال...',
                orElse: () => 'إرسال البلاغ',
              ),
              onPressed: () => _submit(context),
              isLoading: state.maybeWhen(
                loading: () => true,
                orElse: () => false,
              ),
            );
          },
        ),
      ],
    ),
  );
}

  void _submit(BuildContext context) {
    if (selectedTypeId == null ||
        selectedSeverity == null ||
        selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول المطلوبة')),
      );
      return;
    }

    if (widget.descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('برجاء كتابة وصف الأزمة')));
      return;
    }

    final location = context.read<MapCubit>().state.selectedLocation;

    String? typeName;
    try {
      context.read<AllIncidentTypeCubit>().state.maybeWhen(
        loaded: (types) {
          final match = types.where((t) => t.incidentTypeId == selectedTypeId);
          if (match.isNotEmpty) typeName = match.first.incidentTypeName;
        },
        orElse: () {},
      );
    } catch (_) {}

    final branchName = selectedBranchName ??
        (_branches.where((b) => b.branchId == selectedBranchId).isNotEmpty
            ? _branches.firstWhere((b) => b.branchId == selectedBranchId).branchName
            : null);

    context.read<AddIncidentCubit>().submitIncident(
      model: CurrentIncidentModel(
        currentIncidentTypeId: selectedTypeId!,
        currentIncidentSeverity: selectedSeverity!,
        branchId: selectedBranchId!,
        currentIncidentXAxis: location?.latitude,
        currentIncidentYAxis: location?.longitude,
        currentIncidentDescription: widget.descriptionController.text.trim(),
        currentIncidentNotes: widget.notesController.text.trim().isEmpty
            ? null
            : widget.notesController.text.trim(),
        address: widget.addressController.text.trim().isEmpty
            ? null
            : widget.addressController.text.trim(),
        currentIncidentStatus: 1,
        branchName: branchName,
        currentIncidentTypeName: typeName,
      ),
    );
  }
}
