# CRUD AUTHORS

    interface Identifier {
        code: X-ACCOUNT | SCOPUS-AUTHOR-ID | ORCID | WOS-RESEARCHER-ID | CID | POP-ID,
        value: string;
    }

### CREATE NEW AUTHOR

POST /api/person/new

    {
        year_of_birth?: number,
        identifiers: Identifier[]
        first_name?: string,
        last_name: string,
        departments?: number[],
    },

### EDIT AUTHOR

PUT /api/person/edit

    {
        id: number,
        year_of_birth?: number,
        identifiers: Identifier[]
        first_name?: string,
        last_name: string,
        departments?: number[],
    },

### DELETE AUTHOR FROM POST

POST /api/person/post_id/person_id

### CHANGE DEPARTMENT / AFFILATION

### GET LIST OF VERIFIED/UNVERIFIED AUTHORS FOR A SPECIFIC POST WITH SUGGESTED DEPARTMENT(S)

GET /api/person/suggest/post_id : author[]

    [{
        id: number,
        year_of_birth: number,
        x_account: string,
        identifiers: Identifier[]
        full_name: string,
        departments: [],
        verfified: boolean
    }]
