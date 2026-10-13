namespace Raceway.Models.ViewModels
{
    public class UserRolesViewModel
    {
        public String UserId {  get; set; } = string.Empty;
        public String Email { get; set; } = string.Empty;
        public String UserName { get; set; } = string.Empty;
        public IEnumerable<string> Roles { get; set; } = new List<string>();

    }
}
