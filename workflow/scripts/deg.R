pacman::p_load(Seurat)
pacman::p_load(optparse)

#### Parameter configuration -----
option_list <- list(
  make_option(c("-i", "--input"),
    type = "character", default = FALSE,
    action = "store", help = "Seurat Object"
  ),
  make_option(c("-o", "--output"),
    type = "character", default = FALSE,
    action = "store", help = "Output Path"
  ),
  make_option(c("-g", "--group"),
    type = "character", default = FALSE,
    action = "store", help = "Group"
  ),
  make_option(c("-t", "--treatment"),
    type = "character", default = FALSE,
    action = "store", help = "Positive group"
  ),
  make_option(c("-a", "--assay"),
    type = "character", default = FALSE,
    action = "store", help = "Assay"
  ),
  make_option(c("-m", "--method"),
    type = "character", default = FALSE,
    action = "store", help = "Test method"
  )
)
opt <- parse_args(OptionParser(
  option_list = option_list,
  usage = "This Script is a test for arguments!"
))
print(opt)

seurat.obj <- readRDS(opt$input)
seurat.obj$cell_type <- as.character(seurat.obj$cell_type)
selected.group <- opt$group
seurat.obj$tmp.group <- seurat.obj@meta.data[, selected.group]
print(table(seurat.obj$tmp.group))

seurat.obj$celltype.group <-
  paste(seurat.obj$cell_type,
    seurat.obj$tmp.group,
    sep = "_"
  )
print(table(seurat.obj$celltype.group))

cell.types <- names(table(seurat.obj$cell_type))
groups <- names(table(seurat.obj$tmp.group))
positive.group <- groups[which(groups == opt$treatment)]
negative.group <- groups[which(groups != opt$treatment)]

# 使用FindMarkers函数寻找差异表达基因
DefaultAssay(seurat.obj) <- opt$assay
Idents(seurat.obj) <- "celltype.group"
deg <- data.frame()
for (cell.type in cell.types) {
  markers <- FindMarkers(
    seurat.obj,
    ident.1 = paste0(cell.type, "_", positive.group),
    ident.2 = paste0(cell.type, "_", negative.group),
    min.pct = 0,
    logfc.threshold = 0,
    test.use = opt$method
  )
  markers$cell_type <- cell.type
  markers$gene <- rownames(markers)
  deg <- rbind(deg, markers)
}
write.csv(deg,
  file = opt$output,
  quote = F,
  row.names = F
)
