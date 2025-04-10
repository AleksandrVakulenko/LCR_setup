function a = get_ammeter_variants(ammeter_model)
arguments
    ammeter_model {mustBeMember(ammeter_model, ["DLPCA200", "K6517b"])}
end
a = ammeter_model;
end
