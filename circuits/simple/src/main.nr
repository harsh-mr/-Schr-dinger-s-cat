use dep::std;
mod data;

fn concatenate(data: data::Data) -> [u8; 4] {
    let mut result = [0; 4];
    let mut cur_i = 0;
    
    for i in 0..2 {
        result[cur_i] = data.d1[i];
        cur_i += 1;
    }
    
    for i in 0..2 {
        result[cur_i] = data.d2[i];
        cur_i += 1;
    }
    result
}

fn verify_data_provenance(
    data: data::Data,
    keys: data::Keys,
    provenance: data::Provenance
) -> Field {
    let flat_data = concatenate(data);
    let digest256 = std::sha256::digest(flat_data);
    
    if std::schnorr::verify_signature(
        keys.pub_key_x,
        keys.pub_key_y,
        provenance.signature,
        digest256
    ) {
        1
    } else {
        0
    }
}

fn perform_computation_on_data(data: data::Data) -> u8 {
    let mut result = data.d1[0];
    result = 0;
    result
}

fn main(
    public: pub data::Public,
    private: data::Private,
) {
    assert(verify_data_provenance(private.data, public.keys, private.provenance) == 1);
    let result = perform_computation_on_data(private.data);
    assert(result == public.statement.value);
}

        