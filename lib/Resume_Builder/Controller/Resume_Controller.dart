import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:templink/Resume_Builder/Models/resume_model.dart';

import 'package:templink/Resume_Builder/Models/templates_data.dart';

class ResumeController extends GetxController {
  // Current step
  var currentStep = 0.obs;
  
  // Templates
  var templates = TemplatesData.getTemplates().obs;
  var selectedTemplateIndex = 0.obs;
  var selectedTemplate = Rx<ResumeTemplate?>(null);

  // Resume Data
  var resumeData = Rx<ResumeModel?>(null);
  
  // Form Controllers
  // Personal Info
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var professionController = TextEditingController();
  var cityController = TextEditingController();
  var zipCodeController = TextEditingController();
  var provinceController = TextEditingController();
  var phoneController = TextEditingController();
  var emailController = TextEditingController();
  var profileImage = Rx<MemoryImage?>(null);

  // Experience
  var experiences = <Experience>[].obs;
  var expTitleController = TextEditingController();
  var expCompanyController = TextEditingController();
  var expLocationController = TextEditingController();
  var expIsRemote = false.obs;
  var expStartDate = Rx<DateTime?>(null);
  var expEndDate = Rx<DateTime?>(null);
  var expIsCurrent = false.obs;
  var expDescriptionController = TextEditingController();
  var expAchievements = <String>[].obs;
  var expAchievementController = TextEditingController();

  // Education
  var educations = <Education>[].obs;
  var eduInstitutionController = TextEditingController();
  var eduDegreeController = TextEditingController();
  var eduFieldController = TextEditingController();
  var eduGraduationDate = Rx<DateTime?>(null);
  var eduGpaController = TextEditingController();

  // Skills
  var skills = <String>[].obs;
  var skillController = TextEditingController();

  // Summary
  var summaryController = TextEditingController();

  // Languages
  var languages = <Language>[].obs;
  var langNameController = TextEditingController();
  var selectedLangProficiency = 'Fluent'.obs;
  var proficiencies = ['Basic', 'Conversational', 'Fluent', 'Native'].obs;

  // Social Links
  var socialLinks = <SocialLink>[].obs;
  var linkTypeController = ''.obs;
  var linkUrlController = TextEditingController();
  var linkTypes = ['LinkedIn', 'Portfolio', 'GitHub', 'Behance', 'Dribbble', 'Website'].obs;

  @override
  void onInit() {
    super.onInit();
    selectedTemplate.value = templates[0];
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    professionController.dispose();
    cityController.dispose();
    zipCodeController.dispose();
    provinceController.dispose();
    phoneController.dispose();
    emailController.dispose();
    expTitleController.dispose();
    expCompanyController.dispose();
    expLocationController.dispose();
    expDescriptionController.dispose();
    expAchievementController.dispose();
    eduInstitutionController.dispose();
    eduDegreeController.dispose();
    eduFieldController.dispose();
    eduGpaController.dispose();
    skillController.dispose();
    summaryController.dispose();
    langNameController.dispose();
    linkUrlController.dispose();
    super.onClose();
  }

  void selectTemplate(int index) {
    selectedTemplateIndex.value = index;
    selectedTemplate.value = templates[index];
  }

  void nextStep() {
    if (currentStep.value < 6) currentStep.value++;
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  // Experience Methods
  void addExperience() {
    if (expTitleController.text.isNotEmpty && 
        expCompanyController.text.isNotEmpty &&
        expStartDate.value != null) {
      
      experiences.add(Experience(
        title: expTitleController.text,
        company: expCompanyController.text,
        location: expLocationController.text,
        isRemote: expIsRemote.value,
        startDate: expStartDate.value!,
        endDate: expIsCurrent.value ? null : expEndDate.value,
        isCurrent: expIsCurrent.value,
        description: expDescriptionController.text,
        achievements: expAchievements.toList(),
      ));

      // Clear form
      expTitleController.clear();
      expCompanyController.clear();
      expLocationController.clear();
      expIsRemote.value = false;
      expStartDate.value = null;
      expEndDate.value = null;
      expIsCurrent.value = false;
      expDescriptionController.clear();
      expAchievements.clear();
      expAchievementController.clear();
    }
  }

  void addAchievement() {
    if (expAchievementController.text.isNotEmpty) {
      expAchievements.add(expAchievementController.text);
      expAchievementController.clear();
    }
  }

  void removeAchievement(int index) {
    expAchievements.removeAt(index);
  }

  void removeExperience(int index) {
    experiences.removeAt(index);
  }

  // Education Methods
  void addEducation() {
    if (eduInstitutionController.text.isNotEmpty &&
        eduDegreeController.text.isNotEmpty &&
        eduGraduationDate.value != null) {
      
      educations.add(Education(
        institution: eduInstitutionController.text,
        degree: eduDegreeController.text,
        fieldOfStudy: eduFieldController.text,
        graduationDate: eduGraduationDate.value!,
        gpa: double.tryParse(eduGpaController.text),
      ));

      // Clear form
      eduInstitutionController.clear();
      eduDegreeController.clear();
      eduFieldController.clear();
      eduGraduationDate.value = null;
      eduGpaController.clear();
    }
  }

  void removeEducation(int index) {
    educations.removeAt(index);
  }

  // Skills Methods
  void addSkill() {
    if (skillController.text.isNotEmpty) {
      skills.add(skillController.text);
      skillController.clear();
    }
  }

  void removeSkill(int index) {
    skills.removeAt(index);
  }

  // Languages Methods
  void addLanguage() {
    if (langNameController.text.isNotEmpty) {
      languages.add(Language(
        name: langNameController.text,
        proficiency: selectedLangProficiency.value,
      ));
      langNameController.clear();
      selectedLangProficiency.value = 'Fluent';
    }
  }

  void removeLanguage(int index) {
    languages.removeAt(index);
  }

  // Social Links Methods
  void addSocialLink() {
    if (linkTypeController.value.isNotEmpty && linkUrlController.text.isNotEmpty) {
      socialLinks.add(SocialLink(
        type: linkTypeController.value,
        url: linkUrlController.text,
      ));
      linkTypeController.value = '';
      linkUrlController.clear();
    }
  }

  void removeSocialLink(int index) {
    socialLinks.removeAt(index);
  }

  // Build Resume
  void buildResume() {
    // Validate required fields
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        experiences.isEmpty ||
        educations.isEmpty ||
        skills.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Create resume model
    ResumeModel resume = ResumeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      templateId: selectedTemplate.value!.id,
      personalInfo: PersonalInfo(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        profession: professionController.text,
        city: cityController.text,
        zipCode: zipCodeController.text,
        province: provinceController.text,
        phone: phoneController.text,
        email: emailController.text,
        profileImage: profileImage.value?.toString(),
      ),
      experiences: experiences.toList(),
      educations: educations.toList(),
      skills: skills.toList(),
      summary: summaryController.text,
      languages: languages.toList(),
      socialLinks: socialLinks.toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    resumeData.value = resume;
    currentStep.value = 7; // Go to preview step
    
    Get.snackbar(
      'Success',
      'Your professional resume has been created!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}