#[derive(Copy, Debug, Clone)]
#[repr(u8)]
pub enum WindowType {
    UNDEFINED,
    TUMBLING,
    HOPPING,
    ROLLING
 }

impl PartialEq for WindowType {
    fn eq(&self, other: &Self) -> bool {
        match (self, other) {
            (x, y) => *x as u8 == *y as u8,
        }
    }
}

impl WindowType {
    fn from_str(s: &str) -> WindowType{
        match s {
            "TUMBLING" => WindowType::TUMBLING,
            "HOPPING" => WindowType::HOPPING,
            "ROLLING" => WindowType::ROLLING,
            _ => WindowType::UNDEFINED
        }
    }
    fn to_str(t: WindowType) -> String{
        match t {
            WindowType::TUMBLING => "TUMBLING".to_string(),
            WindowType::HOPPING => "HOPPING".to_string(),
            WindowType::ROLLING => "ROLLING".to_string(),
            WindowType::UNDEFINED => "UNDEFINED".to_string()
        }
    }
}

#[test]
fn test_window_type(){
    assert_eq!(WindowType::UNDEFINED, WindowType::UNDEFINED);
    assert_ne!(WindowType::UNDEFINED, WindowType::HOPPING);

    assert_eq!(WindowType::from_str("TUMBLING"), WindowType::TUMBLING);
    assert_ne!(WindowType::from_str("ROLLING"), WindowType::HOPPING);

    assert_eq!(WindowType::to_str(WindowType::from_str("TUMBLING")), "TUMBLING");
    assert_ne!(WindowType::to_str(WindowType::from_str("HOPPING")),  "ROLLING");
}
