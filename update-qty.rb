require 'csv'
require 'fileutils'

in_filename = "Borla.txt"
out_filename = "Borla.txt"
orig_filename = "#{in_filename}.orig"
ref_filename = "turnfourteen.csv"

def map_qty(qty)
  col_mappings = {
    'Out of Stock': 0,
    'Stock Plus': 20,
  }
  key = "#{qty}".to_sym
  col_mappings.has_key?(key) ? col_mappings[key] : qty
end

def is_blank?(val)
  val.nil? or val == ''
end

# make a copy on disk of the original in-file
FileUtils.cp orig_filename, in_filename # ** REMOVE **
FileUtils.cp in_filename, orig_filename

csv_opts = { headers: true, converters: :all, return_headers: true }

# create hash mapping for skus read from in-file
# file = File.new in_filename, 'r'
opts = csv_opts.merge({ col_sep: "\t", return_headers: false })
sku_hash = CSV.foreach(in_filename, opts).reduce({ }) { |hash, row|
  sku = row['sku']
  hash[sku.downcase] = nil unless is_blank?(sku) # skip blanks, downcase sku
  hash
}

# lookup in-file sku occurrences in ref-file and write quantity values to sku_hash
opts = csv_opts.merge({ return_headers: false })
sku_hash = CSV.foreach(ref_filename, opts).reduce(sku_hash) { |hash, row|
  sku = row['InternalPartNumber']
  unless is_blank?(sku) or !hash.has_key?(sku) # skip blanks
    sku = sku.downcase # skus should be case-insensitive
    stock = row['Stock']
    hash[sku] = map_qty(stock) # stock col may have string values, which should be mapped to numerical quantities
  end
  hash
}

# overwrite in-file with updated quantity values from sku_hash
opts = csv_opts.merge({ col_sep: "\t" })
file = File.new orig_filename, 'r'
orig_csv = CSV.new file, opts

CSV.open(out_filename, "wb", { col_sep: "\t" }) { |out_csv|
  out_csv << orig_csv.shift # write header line
  orig_csv.each { |row|
    sku = row['sku']
    row['quantity'] = sku_hash[sku.downcase] unless is_blank?(sku) # skus are case-insensitive
    out_csv << row
  }
  orig_csv.close
}
