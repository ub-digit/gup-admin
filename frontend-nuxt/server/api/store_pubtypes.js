export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig();
    const data = ['journal_article', 'review_article', 'magazine_article', 'editorial_letter'];
    return data;
})