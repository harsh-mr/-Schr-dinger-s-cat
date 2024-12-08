use dep::std;
mod data;

fn concatenate(data: data::Data) -> [u8; 36] {
    let mut result = [0; 36];
    let mut cur_i = 0;
    
    for i in 0..32 {
        result[cur_i] = data.d1[i];
        cur_i += 1;
    }
    
    for i in 0..4 {
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

fn dot_product(x: [u8; 4], y: [u8; 4]) -> u16 {
    let mut result = 0;
    for i in 0..2 {
        result += (x[i] as u16 * y[i] as u16);
    }
    result
}

fn unroll_and_compute(x: [u8; 32], y: [u8; 4]) -> [u16; 8] {
    let mut result = [0; 8];
    for i in 0..8 {
        let start = i * 4;
        let end = start + 4;
        let mut x_slice = [0; 4];
        for j in start..end {
            let slice_index = j - start;
            x_slice[slice_index] = x[j];
            result[i] = dot_product(x_slice, y);
        }
    }
    result
}

fn average(x: [u16; 8]) -> u16 {
    let mut sum: u32 = 0;
    for i in 0..8 {
        sum += x[i] as u32;
    }
    (sum / 8) as u16
}

fn perform_computation_on_data(data: data::Data) -> u16 {
    let dot_products = unroll_and_compute(data.d1, data.d2);
    average(dot_products)
}

fn main(
    public: pub data::Public,
    private: data::Private,
) {
    assert(verify_data_provenance(private.data, public.keys, private.provenance) == 1);
    let result = perform_computation_on_data(private.data);
    assert(result == public.statement.value);
}

        