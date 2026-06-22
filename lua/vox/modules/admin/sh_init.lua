vox:Addon('admin', {
    color = Color(0, 174, 255),
    author = 'Vox UI',
    version = '1.0.0',
    licensee = 'vox-ui'
})

vox.IncludeFolder('vox/modules/admin/core/', true)
vox.admin:Print('Finished loading.')
