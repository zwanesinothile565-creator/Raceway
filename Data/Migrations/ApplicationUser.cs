using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;
namespace Raceway.Models;
// Add profile data for applicatin users by addimg properties to the IdentifyerUser class

public enum Gender
{
    Male,

    Female,

    Other,

    PreferNotToSay
}

public class ApplicationUser : IdentityUser
{
    [Required, MaxLength(50)]
    public string FirstName { get; set; } = string.Empty;

    [Required, MaxLength(50)]
    public string LastName { get; set; } = String.Empty;

    public Gender Gender { get; set; }

    [MaxLength(260)]

    public string? ProfileImagePath { get; set; }


    public string FullName => $"{FirstName} {LastName}";

}

