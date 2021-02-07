#include <iostream>

using byte = unsigned char;

const char* level_names[] = {
    "none", "mobile-lab", "trike-rescue", "bike-race",
    "stego", "sabotage", "isla-1", "river-raft", "sensors",
    "cave-rescue", "transport", "nest-hunt", "isla-2",
    "cave-maze", "isla-3", "isla-4", "egg-hunt", "amber-mine",
    "jungle-fire", "pteranodons", "trex-escape", "countdown",
    "end-sequence", "rough-road", "trex-chase", "arena",
    "end-sequence-2", "combat-mode"
};

char decode_char(byte c) {
    return c < 0x41 ? (c - 0x30) : (c - 0x37);
}

char encode_char(byte c) {
    return c < 10 ? (c + 0x30) : (c + 0x37);
}

void read_password(const char orig_password[9]) {
    std::cout << "Reading password: " << orig_password << "\n";

    char password[9];
    memcpy(password, orig_password, 9);
    
    char c7 = decode_char(password[7]);
    for (int i = 0; i < 7; i++) {
        char c = decode_char(password[i]);
        password[i] = encode_char(c ^ c7);
    }

    byte checksum = 0;
    for (int i = 0; i < 7; i++)
        checksum -= decode_char(password[i]);

    char checksum_ok = (c7 != (checksum & 0x1f));

    byte checksum2 = 0;
    for (int i = 0; i < 6; i++)
        checksum2 = checksum2 ^ decode_char(password[i]);
    if (checksum2 != decode_char(password[6]))
        checksum_ok += '\x02';

    std::cout << "Checksum verification: " << (int)checksum_ok << "\n";
    
    if (checksum_ok != '\0') {
        std::cout << "Invalid password!\n";
        return;
    }

    byte level_ids[] = {4,8,9,6,2,0xa,0xb,0xc,0xd,5,0x18,0xe,0x10,0x17,0x11,0xf};
    bool completed_levels[0x20];
    for (int i = 0; i < 0x20; i++) completed_levels[i] = false;
    char c0 = decode_char(password[0]);
    for (int i = 0; i < 3; i++) {
        if ((c0 >> ((i + 2) & 0x3f)) & 1 != 0)
            completed_levels[level_ids[(c0 & 3) * 4 + i]] = true;
    }
    std::cout << "Completed levels:";
    for (int i = 0; i < 0x20; i++)
        if (completed_levels[i])
            std::cout << " " << level_names[i];
    std::cout << "\n";

    byte starting_level = level_ids[(c0 & 3) * 4];
    std::cout << "Starting level: " << level_names[starting_level] << "\n";

    char c1 = decode_char(password[1]);
    short dif = (c1 & 3);
    std::cout << "Difficulty: " << (dif == 0 ? "easy" : (dif == 1 ? "medium" : "hard")) << " (" << dif << ")\n";
    std::cout << "Music on? " << ((c1 & 4) ? "yes" : "no") << "\n";
    std::cout << "Co-op? " << ((c1 & 8) ? "yes" : "no") << "\n";
    std::cout << "Control 1? " << ((c1 & 0x10) ? "yes" : "no") << "\n";

    char c2 = decode_char(password[2]);
    std::cout << "Two players? " << ((c2 & 1) ? "yes" : "no") << "\n";
    std::cout << "Control scheme: " << ((c2 >> 1) & 7);
}

int main()
{
    read_password("NS22IAH2");
}