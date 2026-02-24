import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────
class ResumeData {
  String fullName = '';
  String professionalTitle = '';
  String phone = '';
  String email = '';
  String location = '';
  String linkedIn = '';
  String github = '';
  String portfolio = '';
  String summary = '';
  List<Experience> experiences = [];
  List<Education> educationList = [];
  List<String> skills = [];
  Map<String, double> skillLevels = {};
  List<Language> languages = [];
  List<Certification> certifications = [];
  List<Award> awards = [];
  List<Project> projects = [];
  List<String> boardMemberships = [];
  List<String> designations = [];
  List<String> tools = [];
  List<String> keyMetrics = [];
}

class Experience {
  String title = '';
  String company = '';
  String location = '';
  String startDate = '';
  String endDate = '';
  bool isCurrent = false;
  List<String> responsibilities = [''];
}

class Education {
  String degree = '';
  String institution = '';
  String location = '';
  String startYear = '';
  String endYear = '';
  String grade = '';
  String honors = '';
}

class Language {
  String name = '';
  String proficiency = 'Fluent';
}

class Certification {
  String name = '';
  String organization = '';
  String year = '';
}

class Award {
  String name = '';
  String organization = '';
  String year = '';
}

class Project {
  String name = '';
  String description = '';
  List<String> technologies = [];
}

// ─────────────────────────────────────────────
//  CONTROLLER
// ─────────────────────────────────────────────
class ResumeController extends GetxController {
  var selectedTemplateId = ''.obs;
  var selectedTemplateAccent = const Color(0xFFF0B429).obs;
  var resumeData = ResumeData().obs;
  var currentStep = 0.obs;
  var refreshTrigger = 0.obs;

  // Validation
  var isPersonalInfoValid = false.obs;
  var isSummaryValid = false.obs;
  var isExperienceValid = false.obs;
  var isEducationValid = false.obs;
  var isSkillsValid = false.obs;

  // Template-specific flags
  var showSkillLevels = false.obs;
  var showCertifications = false.obs;
  var showAwards = false.obs;
  var showProjects = false.obs;
  var showBoardMemberships = false.obs;
  var showDesignations = false.obs;
  var showGPA = false.obs;
  var showKeyMetrics = false.obs;
  var showTools = false.obs;
  var showProfileImage = false.obs; // <-- FIXED: was missing

  void setSelectedTemplate(String id, Color accent) {
    selectedTemplateId.value = id;
    selectedTemplateAccent.value = accent;
    _resetData();
    _configureTemplate(id);
  }

  void _resetData() {
    resumeData.value = ResumeData();
    currentStep.value = 0;
    isPersonalInfoValid.value = false;
    isSummaryValid.value = false;
    isExperienceValid.value = false;
    isEducationValid.value = false;
    isSkillsValid.value = false;
    refreshTrigger.value = 0;
  }

  void _configureTemplate(String id) {
    showSkillLevels.value = false;
    showCertifications.value = false;
    showAwards.value = false;
    showProjects.value = false;
    showBoardMemberships.value = false;
    showDesignations.value = false;
    showGPA.value = false;
    showKeyMetrics.value = false;
    showTools.value = false;
    showProfileImage.value = false;

    switch (id) {
      case 'olivia':
        showSkillLevels.value = true;
        showAwards.value = true;
        showProfileImage.value = false;
        break;
      case 'austin':
        showSkillLevels.value = true;
        showCertifications.value = true;
        showProfileImage.value = true;
        break;
      case 'nova':
        showProjects.value = true;
        showTools.value = true;
        showProfileImage.value = true;
        break;
      case 'ember':
        showSkillLevels.value = true;
        showAwards.value = true;
        showProfileImage.value = true;
        break;
      case 'slate':
        showSkillLevels.value = true;
        showBoardMemberships.value = true;
        showProfileImage.value = true;
        break;
      case 'rose':
        showSkillLevels.value = true;
        showProfileImage.value = true;
        break;
      case 'ats_classic':
        showCertifications.value = true;
        showAwards.value = true;
        showGPA.value = true;
        showProfileImage.value = false;
        break;
      case 'ats_modern':
        showCertifications.value = true;
        showKeyMetrics.value = true;
        showProfileImage.value = false;
        break;
      case 'ats_executive':
        showCertifications.value = true;
        showBoardMemberships.value = true;
        showDesignations.value = true;
        showProfileImage.value = false;
        break;
    }
  }

  void nextStep() {
    if (currentStep.value < 5) currentStep.value++;
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  void goToStep(int s) => currentStep.value = s;

  void _refresh() {
    refreshTrigger.value++;
    resumeData.refresh();
  }

  // ── Validation ──────────────────────────────
  void validatePersonalInfo() {
    final d = resumeData.value;
    isPersonalInfoValid.value =
        d.fullName.trim().isNotEmpty &&
        d.professionalTitle.trim().isNotEmpty &&
        d.phone.trim().isNotEmpty &&
        d.email.trim().isNotEmpty &&
        d.location.trim().isNotEmpty;
  }

  void validateSummary() {
    isSummaryValid.value = resumeData.value.summary.trim().length >= 10;
  }

  void validateExperience() {
    if (resumeData.value.experiences.isEmpty) {
      isExperienceValid.value = false;
      return;
    }
    isExperienceValid.value = resumeData.value.experiences.every(
      (e) => e.title.trim().isNotEmpty && e.company.trim().isNotEmpty && e.startDate.trim().isNotEmpty,
    );
  }

  void validateEducation() {
    if (resumeData.value.educationList.isEmpty) {
      isEducationValid.value = false;
      return;
    }
    isEducationValid.value = resumeData.value.educationList.every(
      (e) =>
          e.degree.trim().isNotEmpty &&
          e.institution.trim().isNotEmpty &&
          e.startYear.trim().isNotEmpty &&
          e.endYear.trim().isNotEmpty,
    );
  }

  void validateSkills() {
    isSkillsValid.value = resumeData.value.skills.isNotEmpty;
  }

  bool isCurrentStepValid() {
    switch (currentStep.value) {
      case 0:
        return isPersonalInfoValid.value;
      case 1:
        return isSummaryValid.value;
      case 2:
        return isExperienceValid.value;
      case 3:
        return isEducationValid.value;
      case 4:
        return isSkillsValid.value;
      case 5:
        return true;
      default:
        return false;
    }
  }

  // ── Experience ──────────────────────────────
  void addExperience() {
    resumeData.value.experiences.add(Experience());
    _refresh();
    validateExperience();
  }

  void removeExperience(int i) {
    resumeData.value.experiences.removeAt(i);
    _refresh();
    validateExperience();
  }

  // ── Education ───────────────────────────────
  void addEducation() {
    resumeData.value.educationList.add(Education());
    _refresh();
    validateEducation();
  }

  void removeEducation(int i) {
    resumeData.value.educationList.removeAt(i);
    _refresh();
    validateEducation();
  }

  // ── Skills ──────────────────────────────────
  void addSkill(String skill) {
    final s = skill.trim();
    if (s.isEmpty || resumeData.value.skills.contains(s)) return;
    resumeData.value.skills.add(s);
    resumeData.value.skillLevels[s] = 0.75;
    _refresh();
    validateSkills();
  }

  void removeSkill(int i) {
    final s = resumeData.value.skills[i];
    resumeData.value.skills.removeAt(i);
    resumeData.value.skillLevels.remove(s);
    _refresh();
    validateSkills();
  }

  void setSkillLevel(String skill, double level) {
    resumeData.value.skillLevels[skill] = level;
    _refresh();
  }

  // ── Languages ───────────────────────────────
  void addLanguage() {
    resumeData.value.languages.add(Language());
    _refresh();
  }

  void removeLanguage(int i) {
    resumeData.value.languages.removeAt(i);
    _refresh();
  }

  // ── Certifications ──────────────────────────
  void addCertification() {
    resumeData.value.certifications.add(Certification());
    _refresh();
  }

  void removeCertification(int i) {
    resumeData.value.certifications.removeAt(i);
    _refresh();
  }

  // ── Awards ──────────────────────────────────
  void addAward() {
    resumeData.value.awards.add(Award());
    _refresh();
  }

  void removeAward(int i) {
    resumeData.value.awards.removeAt(i);
    _refresh();
  }

  // ── Projects ────────────────────────────────
  void addProject() {
    resumeData.value.projects.add(Project());
    _refresh();
  }

  void removeProject(int i) {
    resumeData.value.projects.removeAt(i);
    _refresh();
  }

  // ── Board ────────────────────────────────────
  void addBoardMembership() {
    resumeData.value.boardMemberships.add('');
    _refresh();
  }

  void removeBoardMembership(int i) {
    resumeData.value.boardMemberships.removeAt(i);
    _refresh();
  }

  // ── Designations ─────────────────────────────
  void addDesignation() {
    resumeData.value.designations.add('');
    _refresh();
  }

  void removeDesignation(int i) {
    resumeData.value.designations.removeAt(i);
    _refresh();
  }

  // ── Key Metrics ──────────────────────────────
  void addKeyMetric() {
    resumeData.value.keyMetrics.add('');
    _refresh();
  }

  void removeKeyMetric(int i) {
    resumeData.value.keyMetrics.removeAt(i);
    _refresh();
  }

  // ── Tools ────────────────────────────────────
  void addTool(String tool) {
    final t = tool.trim();
    if (t.isEmpty || resumeData.value.tools.contains(t)) return;
    resumeData.value.tools.add(t);
    _refresh();
  }

  void removeTool(int i) {
    resumeData.value.tools.removeAt(i);
    _refresh();
  }
}