#CRUD AUTHORS

### CREATE NEW AUTHOR

### GET LIST OF VERIFIED/UNV AUTHORS FOR A SPECIFIC POST WITH SUGGESTED DEPARTMENT(S)

api/person/suggest/post_id : author[]

    {
        id: number,
        year_of_birth: number,
        x_account: string,
        full_name: string,
        departments: [],
        verfified: boolean
    },

### DELETE AUTHOR FROM POST

### CHANGE DEPARTMENT / AFFILATION
