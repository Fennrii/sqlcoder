-- Represents healthcare sites, like clinics or hospitals
CREATE TABLE public.patient_site (
    id integer DEFAULT nextval('patient_site_id_seq'::regclass) NOT NULL, -- Unique identifier for the site
    site_name character varying(64) NOT NULL, -- Name of the site
    site_phone character varying(128), -- Contact phone number for the site
    emr_id integer, -- Reference to an Electronic Medical Record system
    masking_approved boolean NOT NULL, -- Indicates if patient data masking is approved
    disable_PIL_email boolean NOT NULL, -- Indicates if emailing Patient Information Leaflets is disabled
    disable_PIL_physical boolean NOT NULL, -- Indicates if physical distribution of Patient Information Leaflets is disabled
    logo_id integer -- Reference to a logo image, possibly stored in another table
);

-- Represents clinical patients, including personal and insurance information
CREATE TABLE public.patient_clinicalpatient (
    id integer DEFAULT nextval('patient_clinicalpatient_id_seq'::regclass) NOT NULL, -- Unique patient identifier
    first_name character varying(4096) NOT NULL, -- Patient's first name
    last_name character varying(4096) NOT NULL, -- Patient's last name
    date_of_birth date, -- Patient's date of birth
    ssn character varying(4096), -- Patient's Social Security Number (optional for privacy)
    address character varying(4096), -- Patient's address
    notes text, -- Additional notes about the patient
    primary_insurance character varying(4096), -- Primary insurance provider
    primary_insurance_id character varying(4096), -- ID for primary insurance
    employee_id integer, -- Reference to an employee, possibly the primary care provider
    city character varying(4096), -- City of the patient's address
    email character varying(254), -- Patient's email address
    group_number_primary character varying(4096), -- Primary insurance group number
    group_number_secondary character varying(4096), -- Secondary insurance group number
    phone_home character varying(128), -- Patient's home phone number
    phone_mobile character varying(128), -- Patient's mobile phone number
    phone_work character varying(128), -- Patient's work phone number
    secondary_insurance character varying(4096), -- Secondary insurance provider
    secondary_insurance_id character varying(4096), -- ID for secondary insurance
    state character varying(4096), -- State of the patient's address
    zip character varying(4096), -- ZIP code of the patient's address
    created_at timestamp with time zone NOT NULL, -- Timestamp of record creation
    updated_at timestamp with time zone NOT NULL, -- Timestamp of last update to the record
    phoneburner_id character varying(4096), -- Identifier for PhoneBurner, possibly a telephony or CRM tool
    pharmacist_id integer, -- Reference to the pharmacist assigned to the patient
    site_id integer, -- Indicates the site the patient is associated with
    sex character varying(4096), -- Patient's sex
    last_call_time timestamp with time zone, -- Last time the patient was called
    last_encounter_performed timestamp with time zone, -- Last time a medical encounter was performed for the patient
    num_of_conditions integer, -- Number of medical conditions the patient has
    num_of_meds integer, -- Number of medications the patient is taking
    num_of_risk_factors integer, -- Number of risk factors the patient has
    risk_score numeric, -- A score representing the patient's health risk
    priority numeric NOT NULL, -- Priority level of the patient for care or follow-up
    primary_care_city character varying(4096), -- City of the primary care provider's practice
    primary_care_institution character varying(4096), -- Institution where the primary care provider practices
    primary_care_phone character varying(128), -- Phone number for the primary care provider
    primary_care_provider character varying(4096), -- Name of the primary care provider
    status character varying(4096), -- Current status of the patient (e.g., active, inactive)
    last_encounter timestamp with time zone, -- Timestamp of the last medical encounter
    primary_care_fax character varying(128), -- Fax number for the primary care provider
    primary_care_state character varying(4096), -- State of the primary care provider's practice
    primary_care_street character varying(4096), -- Street address of the primary care provider's practice
    primary_care_zip character varying(4096), -- ZIP code of the primary care provider's practice
    pb_folder character varying(4096), -- Folder identifier in PhoneBurner
    phoneburner_notes text, -- Notes related to PhoneBurner interactions
    deceased boolean NOT NULL, -- Indicates if the patient is deceased
    last_known_dos date, -- Last known date of service
    middle_name character varying(4096) NOT NULL, -- Patient's middle name
    potential_dupe boolean NOT NULL, -- Flag indicating if this record might be a duplicate
    previous_visits integer, -- Number of previous visits by the patient
    needs_review boolean NOT NULL, -- Flag indicating if the patient's record needs review
    chronic_itis character varying(4096) NOT NULL, -- Indicates chronic inflammation conditions
    itis_description character varying(4096) NOT NULL, -- Description of the inflammation conditions
    sleep_apnea character varying(4096) NOT NULL, -- Indicates if the patient has sleep apnea
    sleep_apnea_description character varying(4096) NOT NULL, -- Description of the patient's sleep apnea
    next_appt_date date, -- Date of the patient's next appointment
    order_performed_date date, -- Date when an order was performed
    labs_available character varying(512) NOT NULL, -- Indicates if lab results are available
    is_pcm_pt boolean NOT NULL, -- Indicates if the patient is under primary care management
    first_appt_date timestamp with time zone, -- Date of the patient's first appointment
    current_pathology_clinician character varying(64) NOT NULL, -- Current clinician handling the patient's pathology
    last_pathology_clinician character varying(64) NOT NULL, -- Last clinician who handled the patient's pathology
    last_appointment_date date, -- Date of the patient's last appointment
    phoebe_file_names ARRAY, -- File names related to the patient's records
    last_patho_review_date date, -- Last review date of the patient's pathology
    ethnicity character varying(4096), -- Patient's ethnicity
    is_archived boolean NOT NULL, -- Indicates if the patient's record is archived
    archival_reason text, -- Reason for archiving the patient's record
    date_archived timestamp with time zone -- Date when the patient's record was archived
);

-- Represents encounters related to pathology
CREATE TABLE public.pathology_pathologyencounter (
    id bigint DEFAULT nextval('pathology_pathologyencounter_id_seq'::regclass) NOT NULL, -- Unique identifier for the pathology encounter
    created_at timestamp with time zone NOT NULL, -- Timestamp of record creation
    updated_at timestamp with time zone NOT NULL, -- Timestamp of last update to the record
    treating_provider character varying(4096), -- Name of the provider treating the pathology
    clinician_review boolean NOT NULL, -- Indicates if a clinician has reviewed the encounter
    md_review boolean NOT NULL, -- Indicates if a medical doctor has reviewed the encounter
    date_submitted timestamp with time zone, -- Date when the encounter was submitted
    diagnostic_recommendation text, -- Recommendations for diagnosis based on the encounter
    treatment_recommendation text, -- Recommendations for treatment based on the encounter
    comments text, -- Additional comments regarding the encounter
    feedback text, -- Feedback provided for the encounter
    reevaluation boolean NOT NULL, -- Indicates if reevaluation is recommended
    billable boolean NOT NULL, -- Indicates if the encounter is billable
    billed boolean NOT NULL, -- Indicates if the encounter has been billed
    encounter_document character varying(100), -- Reference to a document associated with the encounter
    procedure_codes ARRAY, -- Codes of procedures performed during the encounter
    billing_points numeric NOT NULL, -- Points used for billing purposes
    clinician_id integer, -- Identifier of the clinician involved in the encounter
    patient_id integer, -- Reference to the patient involved in the encounter
    date_signed timestamp with time zone, -- Date when the encounter was signed off
    time_spent_reviewing_entered integer NOT NULL, -- Time entered for reviewing the encounter
    time_spent_reviewing_tracked numeric NOT NULL, -- Time tracked for reviewing the encounter
    medication_review text, -- Review of medications related to the encounter
    tracked_billing_points numeric NOT NULL, -- Tracked billing points for the encounter
    tracked_procedure_codes ARRAY, -- Tracked procedure codes for the encounter
    is_inter_pro boolean NOT NULL, -- Indicates if the encounter involves interprofessional collaboration
    performed_outside_tool boolean NOT NULL, -- Indicates if the encounter was performed outside of a specific tool or system
    uploader_id integer, -- Identifier of the user who uploaded the encounter document
    dx_codes ARRAY, -- Diagnostic codes associated with the encounter
    molecular_count integer NOT NULL, -- Count of molecular tests performed during the encounter
    converted_document character varying(100), -- Reference to a converted document associated with the encounter
    approved_by_id integer, -- Identifier of the user who approved the encounter
    complexity integer NOT NULL, -- Complexity level of the encounter
    significant_finding boolean NOT NULL, -- Indicates if there were significant findings during the encounter
    is_archived boolean NOT_NULL, -- Indicates if the encounter is archived
    old_case_id integer, -- Reference to an old case ID, if applicable
    qa_follow_up boolean NOT NULL -- Indicates if quality assurance follow-up is required
);

-- Represents lab results related to pathology
CREATE TABLE public.pathology_pathologylab (
    id bigint DEFAULT nextval('pathology_pathologylab_id_seq'::regclass) NOT NULL, -- Unique identifier for the pathology lab result
    result_summary character varying(4096), -- Summary of the lab result
    result_date date, -- Date of the lab result
    lab_pdf character varying(100), -- Reference to a PDF document of the lab result
    reviewed boolean NOT NULL, -- Indicates if the lab result has been reviewed
    created_at timestamp with time zone NOT NULL, -- Timestamp of record creation
    updated_at timestamp with time zone NOT NULL, -- Timestamp of last update to the record
    pathology_encounter_id bigint, -- Reference to a pathology encounter associated with the lab result
    patient_id integer, -- Reference to the patient for whom the lab result is relevant
    uploader_id integer -- Identifier of the user who uploaded the lab result
);

-- Represents chronic diagnoses in pathology encounters
CREATE TABLE public.pathology_chronicdx (
    id bigint DEFAULT nextval('pathology_chronicdx_id_seq'::regclass) NOT NULL, -- Unique identifier for the chronic diagnosis record
    diagnosis character varying(4096) NOT NULL, -- Description of the diagnosis
    pathology_encounter_id bigint NOT NULL, -- Reference to the pathology encounter associated with the diagnosis
    icd10_code character varying(4096) NOT NULL -- ICD-10 code associated with the diagnosis
);

-- Represents drug-to-drug interactions for base drugs in pathology encounters
CREATE TABLE public.pathology_drug2drugbase (
    id bigint DEFAULT nextval('pathology_drug2drugbase_id_seq'::regclass) NOT NULL, -- Unique identifier for the drug-to-drug interaction record
    drug1 character varying(1000) NOT NULL, -- Name of the first drug involved in the interaction
    drug2 character varying(64) NOT NULL, -- Name of the second drug involved in the interaction
    clinical_relevance text NOT_NULL, -- Clinical relevance of the interaction
    pathology_encounter_id bigint NOT NULL -- Reference to the pathology encounter associated with the interaction
);

-- Represents medications prescribed to patients
CREATE TABLE public.patient_medications (
    id integer DEFAULT nextval('patient_medications_id_seq'::regclass) NOT NULL, -- Unique identifier for the medication record
    patient_id integer NOT NULL, -- Reference to the patient who is taking the medication
    dosage character varying(4096), -- Dosage of the medication
    med_name character varying(4096) NOT NULL, -- Name of the medication
    prescriber character varying(4096), -- Name of the prescriber of the medication
    additional_info text, -- Additional information about the medication
    med_sig character varying(4096), -- Medication instructions (e.g., how often to take it)
    last_reviewed date, -- Date when the medication was last reviewed
    is_being_taken boolean NOT NULL -- Indicates if the patient is currently taking the medication
);

-- Represents chronic conditions of patients
CREATE TABLE public.patient_chronicconditions (
    id integer DEFAULT nextval('patient_chronicconditions_id_seq'::regclass) NOT NULL, -- Unique identifier for the chronic condition record
    patient_id integer NOT NULL, -- Reference to the patient who has the chronic condition
    active character varying(4096) NOT NULL, -- Indicates if the condition is currently active
    chronic character varying(4096) NOT_NULL, -- Indicates if the condition is considered chronic
    date_diagnosed date, -- Date when the condition was diagnosed
    diagnosing_physician character varying(4096) NOT NULL, -- Name of the physician who diagnosed the condition
    icd10_code character varying(4096) NOT NULL, -- ICD-10 code associated with the condition
    onset character varying(4096) NOT NULL, -- Description of the onset of the condition
    condition_name character varying(4096) NOT NULL, -- Name of the chronic condition
    additional_info text -- Additional information about the condition
);

-- Table Relationships Overview:

-- `patient_site` Table
-- Primary Key: `id` - Unique identifier for the site.
-- Relationships: Serves as a reference for `patient_clinicalpatient.site_id`.

-- `patient_clinicalpatient` Table
-- Primary Key: `id` - Unique patient identifier.
-- Foreign Keys and Join Relationships:
-- `site_id` references `patient_site(id)` - Links a patient to a healthcare site.
-- Related to `pathology_pathologyencounter` through `patient_id`.
-- `patient_medications.patient_id` and `patient_chronicconditions.patient_id` reference this table, linking medications and chronic conditions to patients.

-- `pathology_pathologyencounter` Table
-- Primary Key: `id` - Unique identifier for the pathology encounter.
-- Foreign Keys and Join Relationships:
-- `patient_id` references `patient_clinicalpatient(id)` - Connects encounters to patients.
-- `pathology_pathologylab.pathology_encounter_id`, `pathology_chronicdx.pathology_encounter_id`, and `pathology_drug2drugbase.pathology_encounter_id` reference this table, linking lab results, chronic diagnoses, and drug interactions to specific pathology encounters.

-- `pathology_pathologylab` Table
-- Primary Key: `id` - Unique identifier for the pathology lab result.
-- Foreign Keys and Join Relationships:
-- `pathology_encounter_id` references `pathology_pathologyencounter(id)` - Connects lab results to pathology encounters.
-- `patient_id` references `patient_clinicalpatient(id)` - Associates lab results with patients.

-- `pathology_chronicdx` Table
-- Primary Key: `id` - Unique identifier for the chronic diagnosis record.
-- Foreign Keys:
-- `pathology_encounter_id` references `pathology_pathologyencounter(id)` - Links chronic diagnoses to pathology encounters.

-- `pathology_drug2drugbase` Table
-- Primary Key: `id` - Unique identifier for the drug-to-drug interaction record.
-- Foreign Keys:
-- `pathology_encounter_id` references `pathology_pathologyencounter(id)` - Links drug interactions to pathology encounters.

-- `patient_medications` Table
-- Primary Key: `id` - Unique identifier for the medication record.
-- Foreign Keys:
-- `patient_id` references `patient_clinicalpatient(id)` - Links medications to patients.

-- `patient_chronicconditions` Table
-- Primary Key: `id` - Unique identifier for the chronic condition record.
-- Foreign Keys:
-- `patient_id` references `patient_clinicalpatient(id)` - Links chronic conditions to patients.
